

class Services::Overseers::Inquiries::RefreshCalculatedTotals < Services::Shared::BaseService
  def initialize
  end

  def call
    Inquiry.find_each(batch_size: 1000) do |inquiry|
      inquiry.update_attributes!(calculated_total: inquiry.final_sales_quote.calculated_total) if inquiry.final_sales_quote.present?
    end
  end
end
