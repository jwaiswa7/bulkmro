class Services::Overseers::Reports::TargetReport < Services::Overseers::Reports::BaseReport
  def call
    call_base

    @data = OpenStruct.new(
        {
            statuses: [],
            entries: {},
            summary_entries: {}
        }
    )

    #report.start_at = Date.new(2018, 10, 19)
    #report.end_at = Date.today.end_of_day

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

    targets_records = Target.joins(:overseer, :target_period).where('target_periods.period_month' => report.start_at.beginning_of_month..report.end_at.end_of_month)
    inquiries = Inquiry.includes({sales_quotes: [{sales_quote_rows: :supplier}]}, :inside_sales_owner).where('created_at' => report.start_at..report.end_at.end_of_day)
    sales_orders = SalesOrder.includes(:sales_quote_rows, :inquiry).where('created_at' => report.start_at..report.end_at.end_of_day).where('status = ? OR legacy_request_status = ?', 60, 60)
    sales_invoices = SalesInvoice.includes(sales_order: [ { rows: [:product] }]).where('created_at' => report.start_at..report.end_at.end_of_day)

    inside_sales_executive_ids =  Overseer.where(identifier: 'inside').order(first_name: :asc).pluck(:id)

    overseers = Target.where(:overseer_id => inside_sales_executive_ids).top(:overseer_id)
    overseers.each do |overseer_id, count|

      @data.entries[overseer_id] ||= {}
      @data.entries[overseer_id] = { :inquiry_target => 0, :inquiry_achieved => 0, :inquiry_achieved_percentage => 0,
                                     :order_target => 0, :order_achieved => 0, :order_achieved_percentage => 0,
                                     :order_margin_targets_percentage => 0, :order_margin_achieved => 0, :order_margin_achieved_percentage => 0,
                                     :invoice_target => 0, :invoice_achieved => 0, :invoice_achieved_percentage => 0,
                                     :invoice_margin_target_percentage => 0,:invoice_margin_achieved => 0,:invoice_margin_achieved_percentage => 0 }

      targets = targets_records.where(overseer_id: overseer_id).group_by(&:target_type)
      targets.each do |target_type, values|
        if fields.keys.include?(target_type)
          @data.entries[overseer_id][fields[target_type][0]] ||= 0
          @data.entries[overseer_id][fields[target_type][1]] ||= 0
          @data.entries[overseer_id][fields[target_type][2]] ||= 0

          if target_type == 'Inquiry'
            records = inquiries.where(inside_sales_owner_id: overseer_id).order(inquiry_number: :desc).map{|i| i.final_sales_quote.try(:calculated_total).to_f}
          elsif target_type == 'Order'
            records = sales_orders.map{ |so| so if ((so.inside_sales_owner.id if so.inside_sales_owner.present?) == overseer_id || (so.outside_sales_owner.id if so.outside_sales_owner.present?) == overseer_id) }.compact.map{|i| i.try(:calculated_total).to_f}.flatten
          elsif target_type == 'Order Margin'
            records = sales_orders.map{ |so| so if ((so.inside_sales_owner.id if so.inside_sales_owner.present?) == overseer_id || (so.outside_sales_owner.id if so.outside_sales_owner.present?) == overseer_id) }.compact.map{|i| (i.try(:calculated_total) == 0) ? [0] : i.try(:calculated_total_margin).to_f}.flatten
          elsif target_type == 'Invoice'
            records = sales_invoices.map{ |si| si if ((si.sales_order.inside_sales_owner.id if si.sales_order.inside_sales_owner.present?) == overseer_id || (si.sales_order.outside_sales_owner.id if si.sales_order.outside_sales_owner.present?) == overseer_id) }.compact.map{|s| s.metadata['subtotal'].to_f }.compact
          elsif target_type == 'Invoice Margin'
            records = sales_invoices.map{ |si| si if ((si.sales_order.inside_sales_owner.id if si.sales_order.inside_sales_owner.present?) == overseer_id || (si.sales_order.outside_sales_owner.id if si.sales_order.outside_sales_owner.present?) == overseer_id) }.compact.map{|s| products = s.metadata["ItemLine"].pluck("sku"); s.sales_order.rows.joins(:product).where("products.sku IN(?)", products)}.flatten.map{|order| order.try(:total_margin).to_f}.compact
          end

          record_values = (( records.inject(0){|sum,x| sum + x }.to_f ) / 100000).round(2)
          @data.entries[overseer_id][fields[target_type][0]] = values.map{|v| v.target_value}.inject(0){|sum,x| sum + x }.to_f
          @data.entries[overseer_id][fields[target_type][1]] = record_values

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