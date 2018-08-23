class Overseers::InquiryPolicy < Overseers::ApplicationPolicy
  def edit?
    !record.rfqs_generated? && !record.suppliers_selected?
  end

  def new_list_import?
    edit?
  end

  def create_list_import?
    new_list_import?
  end

  def new_excel_import?
    edit?
  end

  def create_excel_import?
    new_excel_import?
  end

  def imports_index?
    show?
  end

  def show_import?
    show?
  end

  def edit_suppliers?
    !record.suppliers_selected?
  end

  def update_suppliers?
    edit_suppliers?
  end

  def edit_rfqs?
    !record.rfqs_generated? && record.suppliers_selected?
  end

  def update_rfqs?
    edit_rfqs?
  end

  def edit_rfqs_mailer_preview?
    edit_rfqs?
  end

  def edit_quotations?
    record.suppliers_selected? && record.rfqs_generated? && !record.sales_quote.present?
  end

  def update_quotations?
    edit_quotations?
  end

  def new_sales_approval?
    record.sales_quote.present? && !record.sales_approval.present?
  end

  def create_sales_approval?
    new_sales_approval?
  end

  def new_sales_order?
    record.sales_approval.present? && !record.sales_order.present?
  end

  def create_sales_order?
    new_sales_order?
  end
end