class TaxRateString < BaseFunction
  def self.for(bill_to, bill_from, ship_from, tax_rate)
    tax_rate = tax_rate
    is_cgst_sgst = (bill_to.country_code == 'IN' && bill_from.present? && ship_from.present?) ? ship_from.state == bill_to.state : false

    if !is_cgst_sgst
      return "IGST #{tax_rate}%"
    else
      return "CGST + SGST #{tax_rate}%"
    end
  end
end
