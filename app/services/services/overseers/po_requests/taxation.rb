class Services::Overseers::PoRequests::Taxation < Services::Shared::BaseService
  def initialize(po_request_row)
    @po_request_row = po_request_row
    @po_request = po_request_row.po_request
    @bill_from = po_request.bill_from
    @ship_from = po_request.ship_from
    @bill_to = po_request.bill_to
    @ship_to = po_request.ship_to
    @purchase_order = po_request.purchase_order
  end

  def call
    @tax_code = po_request_row.best_tax_code
    @tax_rate = po_request_row.best_tax_rate
    # @is_sez = sales_quote.is_sez || (sales_quote.billing_address.present? && sales_quote.billing_address.is_sez)
    @is_service = po_request_row.try(:product).try(:is_service) # || tax_code.is_service

    @is_cgst_sgst = if (bill_to.address.present? && bill_to.address.country_code == 'IN') && bill_from.present? && ship_from.present?
      if is_service
        bill_from.state == ship_to.address.state
      else
        bill_from.state == bill_to.address.state
      end
    else
      false
    end

    @is_igst = !is_cgst_sgst
  end

  def to_s
    if is_igst
      "IGST #{tax_rate.tax_percentage}%"
    else
      "CGST + SGST #{tax_rate.tax_percentage}%"
    end
  end

  # tcs_for_po
  def to_remote_s
    if is_igst
      # if bill_from&.company&.check_company_total_amount(purchase_order) && bill_from&.company&.pan.present? && !is_service
      #   'IG%gT' % ('%.2f' % tax_rate.tax_percentage) + 0.1.to_s
      # elsif bill_from&.company&.check_company_total_amount(purchase_order) && !(bill_from&.company&.pan.present?) && !is_service
      #   'IG%gT' % ('%.2f' % tax_rate.tax_percentage) + 1.to_s
      # else
      #   'IG@%g' % ('%.2f' % tax_rate.tax_percentage)
      # end
      'IG@%g' % ('%.2f' % tax_rate.tax_percentage)
    else
      # if bill_from&.company&.check_company_total_amount(purchase_order) && bill_from&.company&.pan.present?
      #   'CS%gT' % ('%.2f' % tax_rate.tax_percentage) + 0.1.to_s
      # elsif bill_from&.company&.check_company_total_amount(purchase_order) && !(bill_from&.company&.pan.present?)
      #   'CS%gT' % ('%.2f' % tax_rate.tax_percentage) + 1.to_s
      # else
      #   'CSG@%g' % ('%.2f' % tax_rate.tax_percentage)
      # end
      'CSG@%g' % ('%.2f' % tax_rate.tax_percentage)
    end
  end

  def calculated_cgst
    tax_rate.tax_percentage / 2 if !is_igst
  end

  def calculated_sgst
    tax_rate.tax_percentage / 2 if !is_igst
  end

  attr_accessor :po_request, :po_request_row, :bill_to, :ship_to, :ship_from, :bill_from, :tax_code, :tax_rate, :is_service, :is_sez, :is_cgst_sgst, :is_igst, :purchase_order
end
