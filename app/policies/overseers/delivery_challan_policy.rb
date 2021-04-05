# frozen_string_literal: true

class Overseers::DeliveryChallanPolicy < Overseers::ApplicationPolicy
  def index?
    true
  end

  def new?
    manager_or_cataloging? || logistics?
  end

  def autocomplete_supplier?
    index?
  end

  def relationship_map?
    all_roles?
  end
  
  def create_ar_invoice?
    if record.sales_order.present?
      # debugger if record.delivery_challan_number = 'DC-115/20-21'
      product_ids = SalesOrderRow.where(sales_order_id: record.sales_order_id).pluck(:product_id)
      so_rows = record.rows.where(product_id: product_ids)
      if so_rows.present?
        total_quantity = so_rows.pluck(:quantity).compact.sum
      else
        total_quantity = 0
      end
      dc_ar_invoices = ArInvoiceRequest.where('delivery_challan_ids @> ?', [record.id].to_json).where.not(ar_invoice_requests: {status: 'Cancelled AR Invoice'})
      so_ar_invoices = ArInvoiceRequest.where(sales_order_id: record.sales_order_id).where.not(ar_invoice_requests: {status: 'Cancelled AR Invoice'})
      ar_invoices = dc_ar_invoices.present? ? dc_ar_invoices : so_ar_invoices
      delivered_quantity = ArInvoiceRequestRow.where(product_id: record.rows.pluck(:product_id), ar_invoice_request_id: ar_invoices.pluck(:id)).sum(&:delivered_quantity)
      total_quantity != delivered_quantity
    end
  end

end
