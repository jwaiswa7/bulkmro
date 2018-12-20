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

  def new_freight_quote?
    record.freight_quote.blank?
  end

  def edit_freight_quote?
    record.freight_quote.present?
  end
end