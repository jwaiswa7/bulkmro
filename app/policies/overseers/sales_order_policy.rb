class Overseers::SalesOrderPolicy < Overseers::ApplicationPolicy

  def index?
    manager_or_sales? || logistics?
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
    record.persisted? && ['vijay.manjrekar@bulkmro.com','gaurang.shah@bulkmro.com','devang.shah@bulkmro.com'].include?(overseer.email)
  end

  def update_mis_date?
    edit_mis_date?
  end

  def show_pdf?
    record.persisted? && record.sent? && record.order_number.present?
  end

  def show_serialized?
    record.serialized_pdf.attached?
  end

  def edit?
    record == record.sales_quote.sales_orders.latest_record && record.not_sent? && record.not_approved? 
  end

  def update?
    edit? || admin?
  end

  def new_confirmation?
    edit?
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

  def export_all?
    allow_export?
  end

  def export_rows?
    allow_export?
  end

  def export_for_logistics?
    allow_logistics_format_export?
  end

  def drafts_pending?
    admin?
  end

  def go_to_inquiry?
    record.inquiry.can_be_managed?(overseer)
  end

  def can_request_po?
    true #!record.has_purchase_order_request
  end

  def can_request_invoice?
    true #!record.has_purchase_order_request
  end

  def approve?
    pending? && record.sent? && record.not_approved? && !record.rejected? || admin?
  end

  def approve_low_margin?
    approve? && %w(devang.shah@bulkmro.com gaurang.shah@bulkmro.com nilesh.desai@bulkmro.com shravan.agarwal@bulkmro.com vijay.manjrekar@bulkmro.com akshay.jindal@bulkmro.com).include?(overseer.email)
  end

  def reject?
    record.sent? && approve? || admin?
  end

  def resync?
    record.sent? && record.approved? && record.not_synced?
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
          scope.joins(:sales_quote => :inquiry).where('inquiries.inside_sales_owner_id IN (?)', overseer.self_and_descendant_ids)
        elsif overseer.outside?
          scope.joins(:sales_quote => :inquiry).where('inquiries.outside_sales_owner_id IN (?)', overseer.self_and_descendant_ids)
        else
          scope.joins(:sales_quote => :inquiry).where('inquiries.created_by_id IN (?)', overseer.self_and_descendant_ids)
        end
      end
    end
  end

end