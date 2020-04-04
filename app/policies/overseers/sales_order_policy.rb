class Overseers::SalesOrderPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics?
  end

  def cancellation?
    order_cancellation_modal?
  end

  def company_converted_orders?
    manager_or_sales? || logistics?
  end

  def autocomplete?
    manager_or_sales? || logistics?
  end

  def show?
    record.persisted?
  end

  def edit_mis_date?
    record.persisted? && ['vijay.manjrekar@bulkmro.com', 'gaurang.shah@bulkmro.com', 'devang.shah@bulkmro.com', 'nilesh.desai@bulkmro.com', 'bhargav.trivedi@bulkmro.com', 'pradeep.ketkale@bulkmro.com'].include?(overseer.email)
  end

  def update_mis_date?
    edit_mis_date?
  end

  def delivery_date_revision_allowed?
    pod_statuses_of_invoices = record.invoices.map(&:pod_status).uniq
    !(pod_statuses_of_invoices.size == 1 && pod_statuses_of_invoices.last == 'complete')
  end

  def show_pdf?
    record.persisted? && record.sent? && record.order_number.present?
  end

  def show_serialized?
    record.status == 'Approved' && record.order_number.present? && record.serialized_pdf.attached?
  end

  def edit?
    record == record.sales_quote.sales_orders.latest_record && record.not_sent? && record.not_approved? && not_logistics?
  end

  def account_approval?
    record.status == 'Accounts Approval Pending'
  end

  def can_cancel_order?
    record.status == 'Approved' && record.order_number.present?
  end

  def update?
    edit? || admin?
  end

  def new_confirmation?
    edit?
  end

  def new_accounts_confirmation?
    accounts? || admin?
  end

  def create_account_confirmation?
    new_accounts_confirmation?
  end

  def create_confirmation?
    manager_or_sales?
  end

  def new_revision?
    record.persisted? && record.sent? && record.rejected?
  end

  def comments?
    record.persisted?
  end

  def pending?
    manager_or_sales?
  end

  def account_approval_pending?
    accounts? || admin?
  end

  def cancelled?
    manager_or_sales?
  end

  def not_invoiced?
    # have to confirm
    manager_or_sales?
  end

  def export_all?
    allow_export?
  end

  def export_for_reco?
    (developer? || allow_export?) && overseer.can_send_emails?
  end

  def export_rows?
    allow_export?
  end

  def export_for_logistics?
    allow_logistics_format_export?
  end

  def export_for_sap?
    developer? || %w(nilesh.desai@bulkmro.com bhargav.trivedi@bulkmro.com).include?(overseer.email)
  end

  def so_sync_pending?
    admin?
  end

  def go_to_inquiry?
    record.inquiry.can_be_managed?(overseer)
  end

  def can_request_po?
    manager_or_sales? # !record.has_purchase_order_request
  end

  def can_request_invoice?
    admin? || logistics? || manager_or_sales?
  end

  def approve?
    manager? && record.sent? && record.not_approved? && !record.rejected? || admin?
  end

  def approve_low_margin?
    approve? && %w(devang.shah@bulkmro.com gaurang.shah@bulkmro.com nilesh.desai@bulkmro.com vijay.manjrekar@bulkmro.com akshay.jindal@bulkmro.com bhargav.trivedi@bulkmro.com).include?(overseer.email)
  end

  def reject?
    record.sent? && approve? || admin?
  end

  def resync?
    record.sent? && record.approved? && record.not_synced? && admin?
  end

  def sales_order_sync_pending?
    record.order_number.present? && record.remote_uid?
  end

  def new_purchase_orders_requests?
    manager_or_sales?
  end

  def preview_purchase_orders_requests?
    new_purchase_orders_requests?
  end

  def create_purchase_orders_requests?
    new_purchase_orders_requests?
  end

  def fetch_order_data?
    (developer? || admin?) && record.status == 'Approved'
  end

  def material_dispatched_to_customer_new_email_msg?
    (admin? || logistics?)
  end

  def material_dispatched_to_customer_create_email_msg?
    material_dispatched_to_customer_new_email_msg?
  end

  def material_delivered_to_customer_new_email_msg?
    (admin? || logistics?)
  end

  def material_delivered_to_customer_create_email_msg?
    material_delivered_to_customer_new_email_msg?
  end

  def debugging?
    developer?
  end

  def create_stock_po?
    admin? || sales?
  end

  def relationship_map?
    all_roles?
  end

  def get_relationship_map_json?
    relationship_map?
  end

  def customer_order_status_report?
    developer? || admin? || manager_or_sales?
  end

  def export_customer_order_status_report?
    developer? || admin? || manager_or_sales?
  end

  def order_cancellation_modal?
    accounts? || admin?
  end

  def order_cancellation_modal_by_isp?
    admin? || inside?
  end

  def can_isp_cancel_so?
    (inside? || admin_or_manager?) && !record.po_requests.present? && !record.invoices.present? && !record.inward_dispatches.present? && !record.outward_dispatches.present? && record.created_at.month == Date.today.month
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
        if overseer.inside?
          scope.joins(sales_quote: :inquiry).where('inquiries.inside_sales_owner_id IN (?)', overseer.self_and_descendant_ids)
        elsif overseer.outside?
          scope.joins(sales_quote: :inquiry).where('inquiries.outside_sales_owner_id IN (?)', overseer.self_and_descendant_ids)
        else
          scope.joins(sales_quote: :inquiry).where('inquiries.created_by_id IN (?)', overseer.self_and_descendant_ids)
        end
      end
    end
  end
end
