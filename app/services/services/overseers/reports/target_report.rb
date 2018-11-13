class Services::Overseers::Reports::TargetReport < Services::Overseers::Reports::BaseReport
  def call
    call_base

    data = OpenStruct.new(
        {
            statuses: [],
            entries: {},
            filters: {},
            selected_filters: {},
            summary_entries: {},
        }
    )

    # report.start_at = Date.new(2018, 10, 19)
    # report.end_at = Date.today.end_of_day

    designation = params[:designation].present? ? params[:designation] : 'Inside'
    data.selected_filters[:designation] = designation
    executive_name = params[:executive].present? ? params[:executive] : nil
    executive_id = Overseer.where(first_name: executive_name.split(" ").first, last_name: executive_name.split(" ").last).first.id if executive_name.present?
    data.selected_filters[:executive] = executive_name
    manager_name = params[:manager].present? ? params[:manager] : nil
    manager_id = Overseer.where(first_name: manager_name.split(" ").first, last_name: manager_name.split(" ").last).first.id if manager_name.present?
    data.selected_filters[:manager] = manager_name
    business_head_name = params[:business_head].present? ? params[:business_head] : nil
    business_head_id = Overseer.where(first_name: business_head_name.split(" ").first, last_name: business_head_name.split(" ").last).first.id if business_head_name.present?
    data.selected_filters[:business_head] = business_head_name

    data.summary_entries[:inquiries] = {:inquiry_target => 0, :inquiry_achieved => 0, :inquiry_achieved_percentage =>  0}
    data.summary_entries[:orders] = {:order_target => 0, :order_achieved => 0, :order_achieved_percentage =>  0}
    data.summary_entries[:invoices] = {:invoice_target => 0, :invoice_achieved => 0, :invoice_achieved_percentage =>  0}


    fields = {
        'Inquiry' => [:inquiry_target, :inquiry_achieved, :inquiry_achieved_percentage],
        'Order' => [:order_target, :order_achieved, :order_achieved_percentage],
        'Invoice' => [:invoice_target, :invoice_achieved, :invoice_achieved_percentage],
    }


    targets_records = Target.joins(:target_period).where('target_periods.period_month' => report.start_at.beginning_of_month..report.end_at.end_of_month).where(target_type: ['Inquiry', 'Invoice', 'Order']).where.not(target_value: 0)
    targets_records_overseers = targets_records.pluck(:overseer_id).uniq


    sales_executives = Overseer.send(designation.downcase).where(id: targets_records_overseers)
    sales_executives_filter_ids = sales_executives.pluck(:id)
    sales_executives = sales_executives.where(id: executive_id) if executive_id.present?
    sales_executives = manager_id.present? ? sales_executives.map{|o| o if (o.parent_id == manager_id)}.compact : sales_executives
    sales_executives = business_head_id.present? ? sales_executives.map{|o| o if (o.parent.parent_id == business_head_id || o.parent_id == business_head_id) if o.parent.present?}.compact : sales_executives
    sales_executive_ids = sales_executives.pluck(:id)

    overseer_ids = targets_records.where(:overseer_id => sales_executive_ids).pluck(:overseer_id).uniq

    data.filters[:executives] ||= []
    data.filters[:managers] ||= []
    data.filters[:business_head] ||= []
    data.filters[:executives] = Overseer.where(id: sales_executives_filter_ids).map{|o| o.full_name}
    data.filters[:managers] = Overseer.where(id: sales_executives_filter_ids).map{|o| o.parent.full_name if o.parent.present?}.compact.uniq
    data.filters[:business_head] = Overseer.where(id: sales_executives_filter_ids).map{|o| o.parent.parent.full_name if o.parent.parent.present? if o.parent.present?}.compact.uniq

    overseer_ids.each do |overseer_id|
      overseer = Overseer.find(overseer_id)
      targets = targets_records.
          where(overseer_id: overseer_id).
          select(' min(target_periods.period_month) as start_month, max(target_periods.period_month) as end_month, overseer_id, manager_id, business_head_id, target_type,sum(target_value) as target_value').
          group(:overseer_id, :manager_id, :business_head_id, :target_type)

      targets.each do |target|

        target_type= target.target_type
        date_range = target.start_month.to_datetime.beginning_of_month..target.start_month.to_datetime.end_of_month
        overseer_hash_key = "#{overseer_id}-#{target.manager_id}-#{target.business_head_id}"

        data.entries[overseer_hash_key] ||= {}

        if fields.keys.include?(target_type)
          data.entries[overseer_hash_key][:executive] = target.overseer.full_name
          data.entries[overseer_hash_key][:manager] = target.manager.full_name
          data.entries[overseer_hash_key][:business_head] = target.business_head.full_name
          if target_type == 'Inquiry'
            records = Inquiry.where('created_at' => date_range).
                where(inside_sales_owner_id: overseer_id).
                or(Inquiry.where('created_at' => date_range).where(outside_sales_owner_id: overseer_id)).
                includes({sales_quotes: [:sales_quote_rows]}, :inside_sales_owner).
                order(inquiry_number: :desc).
                map{|i| i.final_sales_quote.try(:calculated_total).to_f}
          elsif target_type == 'Order'
            records = SalesOrder.
                joins(:inquiry).
                where('created_at' => date_range).
                where('inquiries.inside_sales_owner_id = ?', overseer_id).
                or(SalesOrder.joins(:inquiry).where('created_at' => date_range).where('inquiries.outside_sales_owner_id = ?', overseer_id)).
                where('sales_orders.status = ? OR sales_orders.legacy_request_status = ?', SalesOrder.statuses[:'Approved'], SalesOrder.statuses[:'Approved']).
                includes(:sales_quote_rows, { inquiry: [:inside_sales_owner, :outside_sales_owner] }).compact.
                map{|i| {order_value: (i.try(:calculated_total).to_f), order_margin_value: ((i.try(:calculated_total) == 0) ? [0] : i.try(:calculated_total_margin).to_f)}}.
                map{|o| o[:order_value]}.flatten
          elsif target_type == 'Invoice'
            records = SalesInvoice.joins(:inquiry).
                where('created_at' => date_range).
                where('inquiries.inside_sales_owner_id = ?', overseer_id).
                or(SalesInvoice.joins(:inquiry).where('created_at' => date_range).where('inquiries.outside_sales_owner_id = ?', overseer_id)).
                map{|s| s.metadata['subtotal'].to_f }.compact
          end

          data.entries[overseer_hash_key][fields[target_type][0]] = target.target_value.to_f
          data.entries[overseer_hash_key][fields[target_type][1]] = (( records.inject(0){|sum,x| sum + x }.to_f ) / 100000).round(2)

          if target_type != 'Order Margin' && target_type != 'Invoice Margin'
            data.entries[overseer_hash_key][fields[target_type][2]] = data.entries[overseer_hash_key][fields[target_type][0]] == 0.0 ? 0 : (( data.entries[overseer_hash_key][fields[target_type][1]] / data.entries[overseer_hash_key][fields[target_type][0]] ) * 100).ceil
          end

          if target_type != 'Order Margin' && target_type != 'Invoice Margin'
            data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] = (data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] + data.entries[overseer_hash_key][fields[target_type][0]]).round(2)
            data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] = (data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] + data.entries[overseer_hash_key][fields[target_type][1]]).round(2)
            data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][2]] = data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] == 0 ? 0 : ((data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] / data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]]) * 100).ceil
          end
        end
      end
    end
    data
  end
end