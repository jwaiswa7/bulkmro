class Services::Shared::Migrations::AddCompanySoTotalAmountYearwise < Services::Shared::BaseService
  def calculate_total_so_amount
    Company.includes(:sales_orders).each do |company|
      start_date = Company.current_financial_year_start
      end_date = Company.current_financial_year_end
      sales_orders_total = company.sales_orders.where(created_at: start_date..end_date).where(status: 'Approved').map(&:calculated_total_with_tax).compact.sum
      tcs_applied_from = Date.new(2020, 10, 01)
      begin
        current_year_total_amounts = company.company_transactions_amounts.where(financial_year: Company.current_financial_year)
        if !current_year_total_amounts.present?
          record = company.company_transactions_amounts.build(financial_year: Company.current_financial_year, total_amount: sales_orders_total, amount_reached_to_date: tcs_applied_from)
          record.save
        end
      rescue Exception => e
        puts "sales_order - #{sales_order.order_number}---------#{e.message}"
      end
    end
  end
end
