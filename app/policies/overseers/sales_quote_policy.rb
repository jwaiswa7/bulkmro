class Overseers::SalesQuotePolicy < Overseers::ApplicationPolicy
  def edit?
    record == record.inquiry.sales_quotes.latest_record && record.not_sent?
  end

  def new_revision?
    record == record.inquiry.sales_quotes.latest_record && record.persisted? && record.sent?
  end
end