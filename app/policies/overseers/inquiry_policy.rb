class Overseers::InquiryPolicy < Overseers::ApplicationPolicy
  def edit?
    !record.rfqs_generated? && !record.suppliers_selected?
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
    record.suppliers_selected? && record.rfqs_generated?
  end

  def update_quotations?
    edit_quotations?
  end
end