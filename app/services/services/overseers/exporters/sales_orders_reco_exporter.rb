class Services::Overseers::Exporters::SalesOrdersRecoExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = SalesOrder
    @export_name = 'sales_order_reco'
    @path = Rails.root.join('tmp', filename)
    @columns = ['serial', 'inquiry', 'inquiry_date', 'sales_owner', 'sales_order', 'sales_order_date', 'sales_order_total', 'po_count', 'product_cost']
  end

  def call
    perform_export_later('SalesOrdersRecoExporter',@arguments)
  end

  def build_csv
    model.where(created_at: start_at..end_at).where.not(sales_quote_id: nil, status: 'Cancelled').order(created_at: :desc).includes(:inquiry,:po_requests).each_with_index do |sales_order, index|
      inquiry = sales_order.inquiry
      purchase_order_ids = PoRequest.where(sales_order: sales_order.id).where.not(purchase_order_id: nil).pluck(:purchase_order_id)
      purchase_orders = PurchaseOrder.where(id: purchase_order_ids).where.not(status: 'cancelled')

      rows.push(
        serial: index,
        inquiry: inquiry.inquiry_number,
        inquiry_date: inquiry.created_at.to_date.to_s,
        sales_owner: sales_order.inside_sales_owner.try(:full_name),
        sales_order: sales_order.order_number,
        sales_order_date: sales_order.created_at.to_date.to_s,
        sales_order_total: sales_order.inside_sales_owner.try(:full_name),
        po_count: purchase_orders.count,
        product_cost: purchase_orders.sum(&:calculated_total_without_tax)
                )
    end
    export = Export.create!(export_type: 65, filtered: true, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
