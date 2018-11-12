class Services::Overseers::Reports::TargetReport < Services::Overseers::Reports::BaseReport
  def call
    call_base

    @data = OpenStruct.new(
        {
            statuses: [],
            entries: {},
            filters: {},
            selected_filters: {},
            summary_entries: {}
        }
    )

    # report.start_at = Date.new(2018, 10, 19)
    # report.end_at = Date.today.end_of_day

    designation = params[:designation].present? ? params[:designation] : 'Inside'
    @data.selected_filters[:designation] = designation
    executive_name = params[:executive].present? ? params[:executive] : nil
    executive_id = Overseer.where(first_name: executive_name.split(" ").first, last_name: executive_name.split(" ").last).first.id if executive_name.present?
    @data.selected_filters[:executive] = executive_name
    manager_name = params[:manager].present? ? params[:manager] : nil
    manager_id = Overseer.where(first_name: manager_name.split(" ").first, last_name: manager_name.split(" ").last).first.id if manager_name.present?
    @data.selected_filters[:manager] = manager_name
    business_head_name = params[:business_head].present? ? params[:business_head] : nil
    business_head_id = Overseer.where(first_name: business_head_name.split(" ").first, last_name: business_head_name.split(" ").last).first.id if business_head_name.present?
    @data.selected_filters[:business_head] = business_head_name

    @data.summary_entries[:inquiries] = {:inquiry_target => 0, :inquiry_achieved => 0, :inquiry_achieved_percentage =>  0}
    @data.summary_entries[:orders] = {:order_target => 0, :order_achieved => 0, :order_achieved_percentage =>  0}
    @data.summary_entries[:order_margins] = {:order_margin_targets_percentage => 0, :order_margin_achieved =>  0, :order_margin_achieved_percentage => 0}
    @data.summary_entries[:invoices] = {:invoice_target => 0, :invoice_achieved => 0, :invoice_achieved_percentage =>  0}
    @data.summary_entries[:invoice_margins] = {:invoice_margin_target_percentage => 0, :invoice_margin_achieved => 0, :invoice_margin_achieved_percentage =>  0}


    fields = {
        'Inquiry' => [:inquiry_target, :inquiry_achieved, :inquiry_achieved_percentage],
        'Order' => [:order_target, :order_achieved, :order_achieved_percentage],
        'Order Margin' => [:order_margin_targets_percentage, :order_margin_achieved, :order_margin_achieved_percentage],
        'Invoice' => [:invoice_target, :invoice_achieved, :invoice_achieved_percentage],
        'Invoice Margin' => [:invoice_margin_target_percentage, :invoice_margin_achieved, :invoice_margin_achieved_percentage]
    }

    targets_records = Target.joins(:target_period).where('target_periods.period_month' => report.start_at.beginning_of_month..report.end_at.end_of_month)
    inquiries = Inquiry.includes({sales_quotes: [:sales_quote_rows]}, :inside_sales_owner).where('created_at' => report.start_at..report.end_at.end_of_day) # .includes({sales_quotes: [{sales_quote_rows: :supplier}]}, :inside_sales_owner)
    sales_orders = SalesOrder.includes(:sales_quote_rows, { inquiry: [:inside_sales_owner, :outside_sales_owner] }).where('created_at' => report.start_at..report.end_at.end_of_day).where('status = ? OR legacy_request_status = ?', 60, 60) #
    sales_invoices = SalesInvoice.joins(sales_order: [ { rows: [:product] }]).where('created_at' => report.start_at..report.end_at.end_of_day) #

    sales_executives = Overseer.send(designation.downcase)
    sales_executives_filter_ids = sales_executives.pluck(:id)
    sales_executives = sales_executives.where(id: executive_id) if executive_id.present?
    sales_executives = manager_id.present? ? sales_executives.map{|o| o if (o.parent_id == manager_id)}.compact : sales_executives
    sales_executives = business_head_id.present? ? sales_executives.map{|o| o if (o.parent.parent_id == business_head_id || o.parent_id == business_head_id) if o.parent.present?}.compact : sales_executives

    sales_executive_ids =  sales_executives.pluck(:id)

    overseer_ids = Target.where(:overseer_id => sales_executive_ids).pluck(:overseer_id).uniq

    @data.filters[:executives] ||= []
    @data.filters[:managers] ||= []
    @data.filters[:business_head] ||= []
    @data.filters[:executives] = Overseer.where(id: sales_executives_filter_ids).map{|o| o.full_name}
    @data.filters[:managers] = Overseer.where(id: sales_executives_filter_ids).map{|o| o.parent.full_name if o.parent.present?}.compact.uniq
    @data.filters[:business_head] = Overseer.where(id: sales_executives_filter_ids).map{|o| o.parent.parent.full_name if o.parent.parent.present? if o.parent.present?}.compact.uniq

    overseer_ids.each do |overseer_id|
      overseer = Overseer.find(overseer_id)
      @data.entries[overseer_id] ||= {}

      @data.entries[overseer_id] = { :inquiry_target => 0, :inquiry_achieved => 0, :inquiry_achieved_percentage => 0,
                                     :order_target => 0, :order_achieved => 0, :order_achieved_percentage => 0,
                                     :order_margin_targets_percentage => 0, :order_margin_achieved => 0, :order_margin_achieved_percentage => 0,
                                     :invoice_target => 0, :invoice_achieved => 0, :invoice_achieved_percentage => 0,
                                     :invoice_margin_target_percentage => 0,:invoice_margin_achieved => 0,:invoice_margin_achieved_percentage => 0 }

      @data.entries[overseer_id][:executive] = overseer.full_name
      @data.entries[overseer_id][:manager] = overseer.parent.present? ? overseer.parent.full_name : overseer.full_name
      @data.entries[overseer_id][:business_head] = overseer.parent.present? ? (overseer.parent.parent.present? ? overseer.parent.parent.full_name : overseer.parent.full_name) : overseer.full_name


      inquiry_records = inquiries.where(inside_sales_owner_id: overseer_id).or(inquiries.where(outside_sales_owner_id: overseer_id)).order(inquiry_number: :desc)
      targets = targets_records.where(overseer_id: overseer_id).group_by(&:target_type)
      sales_order_records = sales_orders.map{ |so| so if ((so.inside_sales_owner_id if so.inside_sales_owner_id.present?) == overseer_id || (so.outside_sales_owner_id if so.outside_sales_owner_id.present?) == overseer_id) }.compact.map{|i| {order_value: (i.try(:calculated_total).to_f), order_margin_value: ((i.try(:calculated_total) == 0) ? [0] : i.try(:calculated_total_margin).to_f)}}
      sales_invoice_records = sales_invoices.map{ |si| si if ((si.sales_order.inside_sales_owner_id if si.sales_order.inside_sales_owner_id.present?) == overseer_id || (si.sales_order.outside_sales_owner_id if si.sales_order.outside_sales_owner_id.present?) == overseer_id) }.compact

      targets.each do |target_type, values|
        if fields.keys.include?(target_type)
          @data.entries[overseer_id][fields[target_type][0]] ||= 0
          @data.entries[overseer_id][fields[target_type][1]] ||= 0
          @data.entries[overseer_id][fields[target_type][2]] ||= 0

          if target_type == 'Inquiry'
            records = inquiry_records.map{|i| i.final_sales_quote.try(:calculated_total).to_f}
          elsif target_type == 'Order'
            records = sales_order_records.map{|o| o[:order_value]}.flatten # sales_orders.map{ |so| so if ((so.inside_sales_owner.id if so.inside_sales_owner.present?) == overseer_id || (so.outside_sales_owner.id if so.outside_sales_owner.present?) == overseer_id) }.compact.map{|i| i.try(:calculated_total).to_f}.flatten
          elsif target_type == 'Order Margin'
            records = sales_order_records.map{|o| o[:order_margin_value]}.flatten # sales_orders.map{ |so| so if ((so.inside_sales_owner.id if so.inside_sales_owner.present?) == overseer_id || (so.outside_sales_owner.id if so.outside_sales_owner.present?) == overseer_id) }.compact.map{|i| (i.try(:calculated_total) == 0) ? [0] : i.try(:calculated_total_margin).to_f}.flatten
          elsif target_type == 'Invoice'
            records = sales_invoice_records.map{|s| s.metadata['subtotal'].to_f }.compact
          elsif target_type == 'Invoice Margin'
            records = sales_invoice_records.map{|s| products = (s.metadata["ItemLine"].present? ? s.metadata["ItemLine"].pluck("sku") : []); s.sales_order.rows.joins(:product).where("products.sku IN(?)", products)}.compact.flatten.map{|order| order.try(:total_margin).to_f}.compact
          end

          @data.entries[overseer_id][fields[target_type][0]] = values.map{|v| v.target_value}.inject(0){|sum,x| sum + x }.to_f
          @data.entries[overseer_id][fields[target_type][1]] = (( records.inject(0){|sum,x| sum + x }.to_f ) / 100000).round(2)

          if target_type != 'Order Margin' && target_type != 'Invoice Margin'
            @data.entries[overseer_id][fields[target_type][2]] = @data.entries[overseer_id][fields[target_type][0]] == 0.0 ? 0 : (( @data.entries[overseer_id][fields[target_type][1]] / @data.entries[overseer_id][fields[target_type][0]] ) * 100).ceil
          else
            if target_type == 'Order Margin'
              @data.entries[overseer_id][fields[target_type][2]] = @data.entries[overseer_id][:order_achieved] == 0.0 ? 0 : (( @data.entries[overseer_id][fields[target_type][1]] / @data.entries[overseer_id][:order_achieved] )*100).round(2).ceil
            else
              @data.entries[overseer_id][fields[target_type][2]] = @data.entries[overseer_id][:invoice_achieved] == 0.0 ? 0 : (( @data.entries[overseer_id][fields[target_type][1]] / @data.entries[overseer_id][:invoice_achieved] )*100).round(2).ceil
            end
          end

          if target_type != 'Order Margin' && target_type != 'Invoice Margin'
            @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] = (@data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] + @data.entries[overseer_id][fields[target_type][0]]).round(2)
            @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] = (@data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] + @data.entries[overseer_id][fields[target_type][1]]).round(2)
            @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][2]] = @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] == 0 ? 0 : ((@data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] / @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]]).round(2) * 100).ceil
          else
            if target_type == 'Order Margin'
              @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] = 20
              @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] = (@data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] + @data.entries[overseer_id][fields[target_type][1]]).round(2)
              @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][2]] = @data.summary_entries[:orders][:order_achieved] == 0.0 ? 0 : (( @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] / @data.summary_entries[:orders][:order_achieved] )*100).round(2).ceil
            else
              @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] = 20
              @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] = (@data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] + @data.entries[overseer_id][fields[target_type][1]]).round(2)
              @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][2]] = @data.summary_entries[:invoices][:invoice_achieved] == 0.0 ? 0 : (( @data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] / @data.summary_entries[:invoices][:invoice_achieved] )*100).round(2).ceil
            end
          end
        end
      end
      # overseer = Overseer.find(overseer_id)

      # inquiry_targets = targets.where(target_type: 'Inquiry', overseer_id: overseer_id).sum(:target_value)
      # inquiry_achieved = inquiries.where(inside_sales_owner_id: overseer_id).order(inquiry_number: :desc).map{|i| i.final_sales_quote.try(:calculated_total).to_f}
      # @data.entries[overseer_id][:inquiry_target] = inquiry_targets
      # @data.entries[overseer_id][:inquiry_achieved] = (( inquiry_achieved.inject(0){|sum,x| sum + x }.to_f ) / 100000).round(2)
      # @data.entries[overseer_id][:inquiry_achieved_percentage] = @data.entries[overseer_id][:inquiry_target] == 0 ? 0 : (( @data.entries[overseer_id][:inquiry_achieved] / @data.entries[overseer_id][:inquiry_target] ) * 100).ceil
      #
      # @data.summary_entries[:inquiries][:inquiries_target] = @data.summary_entries[:inquiries][:inquiries_target] + @data.entries[overseer_id][:inquiry_target]
      # @data.summary_entries[:inquiries][:inquiries_achieved] = @data.summary_entries[:inquiries][:inquiries_achieved] + @data.entries[overseer_id][:inquiry_achieved]
      # @data.summary_entries[:inquiries][:inquiries_achieved_percentage] = @data.summary_entries[:inquiries][:inquiries_target] == 0 ? 0 : ((@data.summary_entries[:inquiries][:inquiries_achieved] / @data.summary_entries[:inquiries][:inquiries_target]).round(2) * 100).ceil
      #
      # order_targets = targets.where(target_type: 'Order', overseer_id: overseer_id).sum(:target_value)
      # order_achieved = sales_orders.map{|so| so if ((so.inside_sales_owner.id if so.inside_sales_owner.present?) == overseer_id) }.compact.map{|i| i.try(:calculated_total).to_f}.flatten.inject(0){|sum,x| sum + x }.to_f
      #
      # @data.entries[overseer_id][:order_target] = order_targets
      # @data.entries[overseer_id][:order_achieved] = (order_achieved.to_f / 100000).round(2)
      # @data.entries[overseer_id][:order_achieved_percentage] = @data.entries[overseer_id][:order_target] == 0 ? 0 : (( @data.entries[overseer_id][:order_achieved] / @data.entries[overseer_id][:order_target] ) * 100).ceil
      #
      # @data.summary_entries[:orders][:orders_target] = @data.summary_entries[:orders][:orders_target] + @data.entries[overseer_id][:order_target]
      # @data.summary_entries[:orders][:orders_achieved] = (@data.summary_entries[:orders][:orders_achieved] + @data.entries[overseer_id][:order_achieved]).round(2)
      # @data.summary_entries[:orders][:orders_achieved_percentage] = @data.summary_entries[:orders][:orders_target] == 0 ? 0 : ((@data.summary_entries[:orders][:orders_achieved] / @data.summary_entries[:orders][:orders_target]).round(2) * 100).ceil
      #
      # order_margin_targets_percentage = targets.where(target_type: 'Order Margin', overseer_id: overseer_id).sum(:target_value)
      # order_margin_achieved = sales_orders.map{|so| so if ((so.inside_sales_owner.id if so.inside_sales_owner.present?) == overseer_id) }.compact.map{|i| (i.try(:calculated_total) == 0) ? 0 : i.try(:calculated_total_margin).to_f}.flatten.inject(0){|sum,x| sum + x }.to_f
      #
      # @data.entries[overseer_id][:order_margin_targets_percentage] = order_margin_targets_percentage
      # @data.entries[overseer_id][:order_margin_achieved] = (order_margin_achieved.to_f / 100000).round(2)
      # @data.entries[overseer_id][:order_margin_achieved_percentage] = @data.entries[overseer_id][:order_achieved] == 0.0 ? 0 : (( @data.entries[overseer_id][:order_margin_achieved] / @data.entries[overseer_id][:order_achieved] )*100).ceil
    end
    # group_targets = targets.group_by(&:overseer_id)

    data
  end
end