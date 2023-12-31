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
    record.persisted? && record.quotation_uid.present?
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

  def create_primary_inquiry?
    can_manage_inquiry? || cataloging? || logistics?
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

  def new_rfq_import?
    new_excel_import?
  end

  def rfq_template?
    new_rfq_import?
  end

  def export_all?
    allow_export?
  end

  def export?
    edit?
  end

  def tat_report?
    manager_or_sales? || developer? || admin?
  end

  def export_inquiries_tat?
    tat_report?
  end

  def sales_owner_status_avg?
    tat_report?
  end

  def create_excel_import?
    new_excel_import?
  end

  def imports?
    edit?
  end

  def edit_suppliers?
    edit? && record.inquiry_products.present?
  end

  def update_suppliers?
    edit_suppliers? && not_logistics?
  end

  def link_product_suppliers?
    edit? && record.inquiry_products.present? && edit_suppliers?
  end

  def draft_rfq?
    edit_suppliers?
  end

  def rfq_review?
    record.supplier_rfqs.present?
  end

  def sales_quotes?
    edit? && (new_sales_quote? || record.sales_quotes.present?)
  end

  def new_sales_quote?
    edit? && record.approvals.any? && record.inquiry_product_suppliers.any? && record.sales_quotes.persisted.blank? && record.synced?
  end

  def sales_orders?
    edit? && record.sales_orders.present?
  end


  def has_approved_sales_orders?
    record&.sales_orders&.remote_approved&.any?
  end

  def has_no_approved_sales_orders?
    !has_approved_sales_orders?
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

  def relationship_map?
    stages?
  end

  def get_relationship_map_json?
    relationship_map?
  end

  def resync_inquiry_products?
    developer? && record.inquiry_products.present?
  end

  def resync_unsync_inquiry_products?
    developer? && record.inquiry_products.present?
  end

  def pipeline_report?
    true
  end

  def has_approved_sales_orders?
    record&.sales_orders&.remote_approved&.any?
  end

  def restrict_fields_on_completed_orders?
    has_approved_sales_orders?
  end

  def has_no_approved_sales_orders?
    !has_approved_sales_orders?
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

  def kra_report?
    manager_or_sales? || admin?
  end

  def kra_report_per_sales_owner?
    manager_or_sales? || admin?
  end

  def export_kra_report?
    allowed_user_for_export?
  end

  def bulk_update?
    manager? || admin?
  end

  def suggestion?
    true
  end

  def duplicate?
    record.persisted?
  end

  def export_pipeline_report?
    allowed_user_for_export?
  end

  def next_inquiry_step?
    new?
  end

  def is_acknowledgement_enable?
    record.id.present? && new_email_message?
  end

  def create_new_dc?
    if record.inquiry_products.present?
      total_quantity = 0
      inquiry_quantities = record.inquiry_products.sum(&:quantity)
      inquiry_delivery_challans = record.delivery_challans.where(created_from: 'Inquiry')
      if inquiry_delivery_challans.present?
        inquiry_delivery_challans.each do |dc|
          total_quantity += dc.rows.sum(&:quantity)
        end
      end

      !record.sales_orders.present? && !has_approved_sales_orders? && (total_quantity < inquiry_quantities)
    else
      false
    end
  end

  def edit_products?
    edit?
  end

  def update_products?
    edit_products?
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
