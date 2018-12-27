class Overseers::FreightRequestPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics? || admin?
  end

  def new?
    index?
  end

  def completed?
    index?
  end

  def edit_request?
    manager_or_sales? || admin?
  end

  def new_freight_quote?
    record.freight_quote.blank? && !manager_or_sales?
  end

  def edit_freight_quote?
    record.freight_quote.present? && !manager_or_sales?
  end
end