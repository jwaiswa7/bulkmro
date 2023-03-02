class Services::Overseers::Exporters::InquiriesExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Inquiry
    @export_name = 'inquiries'
    @path = Rails.root.join('tmp', filename)
    @columns = ['inquiry_number', 'order_number', 'created_at', 'customer_committed_date', 'updated_at', 'quote_type', 'quote_date', 'last_quote_date', 'status', 'opportunity_type', 'inside_sales_owner', 'ise_city', 'outside_sales_owner', 'ose_city', 'company_alias', 'company_name', 'customer', 'key_acc_manager', 'subject', 'currency', 'potential amount', 'overall_margin(%)', 'total (Exc. Tax)', 'products count', 'comments', 'reason', 'customer_order_date', 'customer_po_number', 'billing_address', 'shipping_address']
    @start_at = Date.new(2018, 04, 01)
  end

  def call
    perform_export_later('InquiriesExporter', @arguments)
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name, true, @export_time).deliver_now
    if @ids.present?
      records = model.where(id: @ids).order(created_at: :desc)
    else
      records = model.where(created_at: start_at..end_at).order(created_at: :desc)
    end

    @export = Export.create!(export_type: 1, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    records.find_each(batch_size: 100) do |record|
      rows.push(
        inquiry_number: record.inquiry_number,
        order_number: record.sales_orders.pluck(:order_number).compact.join(','),
        created_at: record.created_at.to_date.to_s,
        committed_customer_date: (record.customer_committed_date.present? ? record.customer_committed_date.to_date.to_s : nil),
        updated_at: record.updated_at.to_date.to_s,
        quote_type: record.quote_category,
        quote_date: record.quotation_date.present? ? record.quotation_date : '-',
        last_quote_date: record.final_sales_quote.present? ? record.final_sales_quote.created_at.to_date.to_s : '-',
        status: record.status,
        opportunity_type: record.opportunity_type,
        inside_sales_owner: record.inside_sales_owner.try(:full_name),
        ise_city: record.inside_sales_owner.try(:geography),
        outside_sales_owner: record.outside_sales_owner.try(:full_name),
        ose_city: record.outside_sales_owner.try(:geography),
        company_alias: record.account.try(:name),
        company_name: record.company.try(:name),
        customer: record.contact.to_s,
        key_acc_manager: record.sales_manager.try(:full_name),
        subject: record.subject,
        currency: record.currency.try(:name),
        potential_amount: record.potential_amount,
        overall_margin_percentage: record.overall_margin_percent,
        total: record.final_sales_quote.try(:calculated_total),
        products_count: record.inquiry_products.count,
        comments: record.comments.pluck(:message).join(','),
        reason: '',
        customer_order_date: record.customer_order_date,
        customer_po_number: record.customer_po_number,
        billing_address: record.inquiry&.billing_address&.to_singleline_s,
        shipping_address: record.inquiry&.shipping_address&.to_singleline_s
      )
    end
    # filtered = @ids.present?
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
