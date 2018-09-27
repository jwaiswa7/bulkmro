class Services::Overseers::SalesQuotes::Taxation < Services::Shared::BaseService

  def initialize(sales_quote_row)
    @sales_quote_row = sales_quote_row
    @sales_quote = sales_quote_row.sales_quote
    @bill_to = sales_quote.billing_address
    @ship_to = sales_quote.shipping_address
    @bill_from = sales_quote.bill_from
  end

  def call
    @tax_code = sales_quote_row.best_tax_code
    @is_sez = sales_quote.is_sez || sales_quote.billing_address.is_sez
    @is_service = sales_quote_row.is_service

    @is_cgst_sgst = if bill_to.country_code == 'IN'
                      if is_service
                        bill_from.address.state == ship_to.state
                      else
                        bill_from.address.state == bill_to.state
                      end
                    else
                      false
                    end

    @is_igst = !is_cgst_sgst
  end

  def to_s
    if is_sez
      "0"
    elsif is_igst
      "IGST #{tax_code.tax_percentage}%"
    else
      "CGST + SGST #{tax_code.tax_percentage}%"
    end
  end

  def to_remote_s
    if is_sez
      "0"
    elsif is_igst
      "IG@#{tax_code.tax_percentage}"
    else
      "CSG@#{tax_code.tax_percentage}"
    end
  end

  attr_accessor :sales_quote, :sales_quote_row, :bill_to, :ship_to, :bill_from, :tax_code, :is_service, :is_sez, :is_cgst_sgst, :is_igst
end