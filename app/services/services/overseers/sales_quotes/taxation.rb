

class Services::Overseers::SalesQuotes::Taxation < Services::Shared::BaseService
  def initialize(sales_quote_row)
    @sales_quote_row = sales_quote_row
    @sales_quote = sales_quote_row.sales_quote
    @bill_to = sales_quote.billing_address
    @ship_to = sales_quote.shipping_address
    @bill_from = sales_quote.bill_from
    @ship_from = sales_quote.ship_from
  end

  def call
    @tax_code = sales_quote_row.best_tax_code
    @tax_rate = sales_quote_row.best_tax_rate
    @is_sez = sales_quote.is_sez || (sales_quote.billing_address.present? && sales_quote.billing_address.is_sez)
    @is_service = sales_quote_row.try(:product).try(:is_service) # || tax_code.is_service

    @is_cgst_sgst = if (bill_to.present? && bill_to.country_code == 'IN') && bill_from.present? && ship_from.present?
      if is_service
        ship_from.address.state == bill_to.state
      else
        ship_from.address.state == bill_to.state
      end
    else
      false
    end

    @is_igst = !is_cgst_sgst
  end

  def to_s
    if is_sez
      '0'
    elsif is_igst
      "IGST #{tax_rate.tax_percentage}%"
    else
      "CGST + SGST #{tax_rate.tax_percentage}%"
    end
  end

  def to_remote_s
    if is_sez
      'IG@0'
    elsif is_igst
      'IG@%g' % ('%.2f' % tax_rate.tax_percentage)
    else
      'CSG@%g' % ('%.2f' % tax_rate.tax_percentage)
    end
  end

  def calculated_cgst
    tax_rate.tax_percentage / 2 if !is_igst
  end

  def calculated_sgst
    tax_rate.tax_percentage / 2 if !is_igst
  end

  attr_accessor :sales_quote, :sales_quote_row, :bill_to, :ship_to, :ship_from, :bill_from, :tax_code, :tax_rate, :is_service, :is_sez, :is_cgst_sgst, :is_igst
end
