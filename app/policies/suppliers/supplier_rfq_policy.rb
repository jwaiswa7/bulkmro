# frozen_string_literal: true

class Suppliers::SupplierRfqPolicy < Suppliers::ApplicationPolicy
  def edit_supplier_rfqs?
    true
  end

  def edit_rfq?
    !(record.inquiry.sales_orders.present? && record.inquiry.sales_orders.approved.map { |so| so.sales_quote.supplier_rfq_ids.include?(record.id) }.include?(true))
  end

  def update_ips?
    true
  end
end
