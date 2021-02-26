class Services::Shared::Migrations::CorrectCompanyTotalAmountYearwise < Services::Shared::BaseService
  def customer_companies_correct_total_so_amount
    total_wrong_companies = []
    Company.acts_as_customer.includes(:account).includes(:sales_orders).each do |company|
      start_date = Company.current_financial_year_start
      end_date = Company.current_financial_year_end
      company_total_amount_record = CompanyTransactionsAmount.where(financial_year: Company.current_financial_year, company_id: company.id).last
      sales_orders_total = company.sales_orders.where(created_at: start_date..end_date).where(status: 'Approved').map(&:calculated_total_with_tax).compact.sum
      if company_total_amount_record.total_amount != sales_orders_total
        total_wrong_companies.push(company.id)
        company_total_amount_record.total_amount = sales_orders_total
        company_total_amount_record.save
      end

    end
    puts 'Total companies with wrong values : '+total_wrong_companies.count.inspect
  end
end
