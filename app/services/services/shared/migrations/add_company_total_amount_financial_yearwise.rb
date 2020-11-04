class Services::Shared::Migrations::AddCompanyTotalAmountFinancialYearwise < Services::Shared::BaseService
  def customer_companies_calculate_total_so_amount
    Company.acts_as_customer.includes(:account).includes(:sales_orders).each do |company|
      start_date = Company.current_financial_year_start
      end_date = Company.current_financial_year_end
      company_total_amount_record = CompanyTransactionsAmount.where(financial_year: Company.current_financial_year, company_id: company.id)
      unless company_total_amount_record.present?
        if Date.today == start_date
          sales_orders_total = 0.0
        else
          sales_orders_total = company.sales_orders.where(created_at: start_date..end_date).where(status: 'Approved').map(&:calculated_total_with_tax).compact.sum
        end
        tcs_applied_from = Date.new(2020, 10, 01)
        begin
          record = company.company_transactions_amounts.build(financial_year: Company.current_financial_year, total_amount: sales_orders_total, amount_reached_to_date: tcs_applied_from)
          record.save
        rescue Exception => e
          puts "sales_order company - #{record.company.to_s}---------#{e.message}"
        end
      end
    end
  end

  def supplier_companies_calculate_total_po_amount
    Company.acts_as_supplier.includes(:account).includes(:purchase_orders).each do |company|
      start_date = Company.current_financial_year_start
      end_date = Company.current_financial_year_end
      company_total_amount_record = CompanyTransactionsAmount.where(financial_year: Company.current_financial_year, company_id: company.id).last
      if company_total_amount_record.present?
        if Date.today == start_date
          purchase_orders_total = 0.0
        else
          purchase_orders_total = company.purchase_orders.not_cancelled.where(created_at: start_date..end_date).map(&:calculated_total_with_tax).compact.sum
        end
        begin
          company_total_amount_record.total_amount = purchase_orders_total
          company_total_amount_record.save
        rescue Exception => e
          puts "PO Company - #{company_total_amount_record.company.to_s}---------#{e.message}"
        end
      end
    end
  end
end