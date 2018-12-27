class Overseers::FreightRequestPolicy < Overseers::ApplicationPolicy
  def index?
    manager_or_sales? || logistics?
  end

  def new?
    index?
  end

  def completed?
    index?
  end

  def edit_request?
    manager_or_sales?
  end

  def new_freight_quote?
    record.freight_quote.blank? && (logistics? || admin?)
  end

  def edit_freight_quote?
    record.freight_quote.present? && (logistics? || admin?)
  end

  def show_freight_quote?
    record.freight_quote.present?
  end
end
