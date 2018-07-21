class Overseers::InquiryPolicy < Overseers::ApplicationPolicy
  def edit?
    !record.rfqs_generated? && !record.suppliers_selected?
  end

  def select_suppliers?
    !record.suppliers_selected?
  end

  def suppliers_selected?
    select_suppliers?
  end

  def generate_rfqs?
    !record.rfqs_generated? && record.suppliers_selected?
  end

  def rfqs_generated?
    generate_rfqs?
  end

  def rfqs_generated_mailer_preview?
    true
  end
end