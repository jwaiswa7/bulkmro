

class Services::Overseers::Reports::TargetReport < Services::Overseers::Reports::BaseReport
  def call
    call_base


    report.start_at = Date.new(2018, 11, 1) if report.start_at < Date.new(2018, 11, 1)
    # report.end_at = Date.today.end_of_day

    data = Rails.cache.fetch("#{Digest::MD5.hexdigest params.to_s}/data", expires_in: 10.minutes) do
       headers = [:target, :achieved, :"achieved %"]

       data = OpenStruct.new(
         statuses: [],
         entries: {},
         filters: {},
         headers: headers + headers + headers,
         selected_filters: {},
         summary_entries: {},
         dump: []
       )

       designation = params[:designation].present? ? params[:designation] : "Inside"
       data.selected_filters[:designation] = designation
       executive = params[:executive].present? ? params[:executive] : nil
       executive_id = Overseer.find(executive).id if executive.present?
       data.selected_filters[:executive] = executive_id
       manager = params[:manager].present? ? params[:manager] : nil
       manager_id = Overseer.find(manager).id if manager.present?
       data.selected_filters[:manager] = manager_id
       business_head = params[:business_head].present? ? params[:business_head] : nil
       business_head_id = Overseer.find(business_head).id if business_head.present?
       data.selected_filters[:business_head] = business_head_id

       data.summary_entries[:inquiries] = { inquiry_target: 0, inquiry_achieved: 0, "inquiry_achieved %": 0 }
       data.summary_entries[:orders] = { order_target: 0, order_achieved: 0, "order_achieved %": 0 }
       data.summary_entries[:invoices] = { invoice_target: 0, invoice_achieved: 0, "invoice_achieved %": 0 }


       fields = {
           "Inquiry" => [:inquiry_target, :inquiry_achieved, :"inquiry_achieved %"],
           "Order" => [:order_target, :order_achieved, :"order_achieved %"],
           "Invoice" => [:invoice_target, :invoice_achieved, :"invoice_achieved %"],
       }

       targets_records = Target.joins(:target_period).where("target_periods.period_month" => report.start_at.beginning_of_month..report.end_at.end_of_month).where(target_type: ["Inquiry", "Invoice", "Order"]).where.not(target_value: 0)
       overseer = params[:overseer]

       if overseer.admin?
         child_overseer_ids = targets_records.pluck(:overseer_id).uniq
       elsif overseer.manager?
         child_overseer_ids = overseer.find_all_by_generation(2).pluck(:id) + overseer.find_all_by_generation(1).pluck(:id) + [overseer.id]
       elsif overseer.leader?
         child_overseer_ids = overseer.children.pluck(:id) + [overseer.id]
       else
         child_overseer_ids = [overseer.id]
       end

       target_child_overseer_ids = targets_records.where("manager_id = ? OR business_head_id = ?", overseer.id, overseer.id).pluck(:overseer_id)
       targets_records_overseers = (child_overseer_ids + target_child_overseer_ids).uniq


       sales_executives = Overseer.send("target_#{designation.downcase}").where(id: targets_records_overseers)
       sales_executives_filter_ids = sales_executives.pluck(:id)
       if executive_id.present?
         sales_executives = sales_executives.where(id: executive_id)
       end

       if manager_id.present?
         sales_executives = sales_executives.map{ |o| o if o.parent_id == manager_id }.compact
         sales_executives = (sales_executives + targets_records.includes(:overseer).where(overseer_id: targets_records_overseers, manager_id: manager_id).map{ |t| t.overseer if t.overseer.send("target_#{designation}?".downcase) }.compact).uniq
       end

       if business_head_id.present?
         sales_executives = sales_executives.map{ |o| o if o.parent.parent_id == business_head_id || o.parent_id == business_head_id if o.parent.present? }.compact
         sales_executives = (sales_executives + targets_records.includes(:overseer).where(overseer_id: targets_records_overseers, business_head_id: business_head_id).map{ |t| t.overseer if t.overseer.send("target_#{designation}?".downcase) }.compact).uniq
       end

       sales_executive_ids = sales_executives.pluck(:id)
       all_sales_executives = Overseer.where(id: sales_executives_filter_ids)

       overseer_ids = targets_records.where(overseer_id: sales_executive_ids).pluck(:overseer_id).uniq

       data.filters[:executives] ||= []
       data.filters[:managers] ||= []
       data.filters[:business_head] ||= []
       data.filters[:executives] = all_sales_executives.map { |o| [o.full_name, o.id] }.sort
       data.filters[:managers] = all_sales_executives.map { |o| [o.parent.full_name, o.parent.id] if o.parent.present? }.compact.uniq.sort
       data.filters[:business_head] = all_sales_executives.map { |o| (o.parent.present? ? (o.parent.parent.present? ? [o.parent.parent.full_name, o.parent.parent.id] : [o.parent.full_name, o.parent.id]) : [o.full_name, o.id]) }.compact.uniq.sort

       date_range = report.start_at.beginning_of_month..report.end_at.end_of_month

       inquiries = Inquiry.where("created_at" => date_range).
           includes({ sales_quotes: [{ sales_quote_rows: :inquiry_product_supplier }] }, :inside_sales_owner).
           order(inquiry_number: :desc)
       sales_orders = SalesOrder.
           joins(:inquiry).
           includes(:rows).
           where("mis_date" => date_range).
           where("sales_orders.status = ? OR sales_orders.legacy_request_status = ?", SalesOrder.statuses[:'Approved'], SalesOrder.statuses[:'Approved'])
       sales_invoices = SalesInvoice.joins(:inquiry).
           where("mis_date" => date_range)

       overseer_ids.each do |overseer_id|
         overseer = Overseer.find(overseer_id)
         targets = targets_records.
             where(overseer_id: overseer_id).
             select(" min(target_periods.period_month) as start_month, max(target_periods.period_month) as end_month, overseer_id, manager_id, business_head_id, target_type,sum(target_value) as target_value").
             group(:overseer_id, :manager_id, :business_head_id, :target_type)

         targets.each do |target|
           target_type = target.target_type

           start_date = target.start_month.to_datetime.beginning_of_month < report.start_at ? report.start_at : target.start_month.to_datetime.beginning_of_month
           end_date = target.end_month.to_datetime.end_of_month > report.end_at ? report.end_at : target.end_month.to_datetime.end_of_month

           date_range = start_date..end_date
           overseer_hash_key = "#{overseer_id}-#{target.manager_id}-#{target.business_head_id}"

           data.entries[overseer_hash_key] ||= { executive: "", manager: "", business_head: "", inquiry_target: 0, inquiry_achieved: 0, "inquiry_achieved %": 0, order_target: 0, order_achieved: 0, "order_achieved %": 0, invoice_target: 0, invoice_achieved: 0, "invoice_achieved %": 0 }

           if fields.keys.include?(target_type)


             data.entries[overseer_hash_key][:executive] = target.overseer.full_name
             data.entries[overseer_hash_key][:manager] = target.manager.full_name
             data.entries[overseer_hash_key][:business_head] = target.business_head.full_name
             if target_type == "Inquiry"
               records = inquiries.where("created_at" => date_range).
                   where(inside_sales_owner_id: overseer_id).
                   or(inquiries.where("created_at" => date_range).where(outside_sales_owner_id: overseer_id)).
                   map { |i| i.final_sales_quote.try(:calculated_total).to_f }
             elsif target_type == "Order"
               records = sales_orders.
                   where("inquiries.inside_sales_owner_id = ?", overseer_id).
                   or(sales_orders.where("inquiries.outside_sales_owner_id = ?", overseer_id)).
                   where("mis_date" => date_range).
                   compact.
                   map { |i| (i.try(:calculated_total).to_f) }.flatten
             elsif target_type == "Invoice"
               records = sales_invoices.
                   where("inquiries.inside_sales_owner_id = ?", overseer_id).
                   or(sales_invoices.where("inquiries.outside_sales_owner_id = ?", overseer_id)).
                   where("mis_date" => date_range).map do |sales_invoice|
                     if sales_invoice.metadata.present?
                       sales_invoice.metadata["subtotal"].to_f
                     elsif sales_invoice.report_total.present?
                       sales_invoice.report_total.to_f
                     else
                       nil
                     end
                   end.compact
             end

             data.entries[overseer_hash_key][fields[target_type][0]] = target.target_value.to_f.round(2)
             data.entries[overseer_hash_key][fields[target_type][1]] = ((records.inject(0) { |sum, x| sum + x }.to_f) / 100000).round(2)
             data.entries[overseer_hash_key][fields[target_type][2]] = data.entries[overseer_hash_key][fields[target_type][0]] == 0.0 ? 0 : ((data.entries[overseer_hash_key][fields[target_type][1]] / data.entries[overseer_hash_key][fields[target_type][0]]) * 100).ceil

             data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] += data.entries[overseer_hash_key][fields[target_type][0]].round(2)
             data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] += data.entries[overseer_hash_key][fields[target_type][1]].round(2)
             data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][2]] = data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]] == 0 ? 0 : ((data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][1]] / data.summary_entries[target_type.split(" ").join("_").downcase.pluralize.to_sym][fields[target_type][0]]) * 100).ceil

           end
         end
       end

       data
     end

    data
  end
end
