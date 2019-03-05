class Overseers::InquiryPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || cataloging? || logistics?
  end

  def new_from_customer_order?
    manager_or_sales? || cataloging? || logistics?
  end

  def index_pg?
    index?
  end

  def disable_billing_shipping_details?
    record.persisted? && record.sales_quote.remote_uid.present?
  end

  def smart_queue?
    manager_or_sales?
  end

  def new_email_message?
    record.persisted? && overseer.can_send_emails?
  end

  def create_email_message?
    new_email_message?
  end

  def can_manage_inquiry?
    record.can_be_managed?(overseer)
  end

  def edit?
    can_manage_inquiry? || cataloging? || logistics?
  end

  def update?
    not_logistics?
  end

  def new_list_import?
    edit?
  end

  def create_list_import?
    new_list_import?
  end

  def excel_template?
    new_excel_import?
  end

  def new_excel_import?
    edit?
  end

  def export_all?
    allow_export?
  end

  def export?
    edit?
  end

  def create_excel_import?
    new_excel_import?
  end

  def imports?
    edit? && not_logistics?
  end

  def edit_suppliers?
    edit? && record.inquiry_products.present?
  end

  def update_suppliers?
    edit_suppliers? && not_logistics?
  end

  def sales_quotes?
    edit? && (new_sales_quote? || record.sales_quotes.present?) && not_logistics?
  end

  def new_sales_quote?
    edit? && record.approvals.any? && record.inquiry_product_suppliers.any? && record.sales_quotes.persisted.blank?
  end

  def sales_orders?
    edit? && record.sales_orders.present?
  end

  def calculation_sheet?
    edit?
  end

  def comments?
    edit?
  end

  def purchase_orders?
    edit? && record.purchase_orders.present?
  end

  def sales_shipments?
    edit? && record.shipments.present?
  end

  def sales_invoices?
    edit? && record.invoices.present?
  end

  def stages?
    edit?
  end

  def resync_inquiry_products?
    developer? && record.inquiry_products.present?
  end

  def resync_unsync_inquiry_products?
    developer? && record.inquiry_products.present?
  end


  def new_freight_request?
    !record.freight_request.present? && !logistics?

  end

  def preview_stock_po_request?
    developer? || sales? || admin?
  end

  def create_purchase_orders_requests?
    developer? || sales? || admin?
  end

  class Scope
    attr_reader :overseer, :scope

    def initialize(overseer, scope)
      @overseer = overseer
      @scope = scope
    end

    def resolve
      if overseer.manager?
        scope.all
      else
        scope.where('inside_sales_owner_id IN (:overseer_ids) OR outside_sales_owner_id IN (:overseer_ids)', overseer_ids: overseer.self_and_descendant_ids)
      end
    end
  end
end
