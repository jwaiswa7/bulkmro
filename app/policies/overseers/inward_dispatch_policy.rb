class Overseers::InwardDispatchPolicy < Overseers::ApplicationPolicy
  def inward_dispatch_pickup_queue?
    admin? || logistics? || sales?
  end

  def inward_dispatch_delivered_queue?
    admin? || logistics? || sales?
  end

  def inward_completed_queue?
    admin? || logistics? || sales?
  end

  def delivered_material?
    true
  end

  def edit?
    admin? || logistics? || sales? && record.status != 'Material Delivered'
  end

  def can_request_invoice?
    !record.invoice_request.present? || (record.invoice_request.present? && record.invoice_request.status == 'Cancelled GRPO')
  end

  def confirm_delivery?
    record.status == 'Material Pickup'
  end

  def add_products?
    record.status == 'Material Pickup' && !(record.purchase_order.rows.count == 1)
  end

  def remove_products?
    add_products?
  end

  def delivered?
    record.status == 'Material Delivered'
  end

  def update_logistics_owner_for_inward_dispatches?
    if record.class == Symbol
      admin?
    else
      admin? && (record.status != 'Material Delivered')
    end
  end
  def cancelled_inward_dispatches?
    true
  end

  def create_ar_invoice?
    if record.sales_order.present?
      product_ids = SalesOrderRow.where(sales_order_id: record.sales_order_id).pluck(:product_id)
      so_rows = record.rows.where(product_id: product_ids)
      if so_rows.present?
        total_quantity = so_rows.pluck(:delivered_quantity).compact.sum
      else
        total_quantity = 0
      end
      ar_invoices = ArInvoiceRequest.where('inward_dispatch_ids @> ?', [record.id].to_json).where.not(ar_invoice_requests: {status: 'Cancelled AR Invoice'})
      delivered_quantity = ArInvoiceRequestRow.where(product_id: record.rows.pluck(:product_id),ar_invoice_request_id: ar_invoices.pluck(:id)).sum(&:delivered_quantity)
      total_quantity != delivered_quantity
    end
  end

  def create_new_dc?
    total_quantity = 0
    inward_dispatch_delivered_quantities = record.rows.sum(&:delivered_quantity)
    if record.delivery_challans.present?
      record.delivery_challans.each do |dc|
        total_quantity += dc.rows.sum(&:quantity)
      end
    end

    total_quantity < inward_dispatch_delivered_quantities
  end
end
