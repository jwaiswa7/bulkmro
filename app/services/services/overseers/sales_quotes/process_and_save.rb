class Services::Overseers::SalesQuotes::ProcessAndSave < Services::Shared::BaseService
  def initialize(sales_quote)
    @sales_quote = sales_quote
  end

  def call
    if sales_quote.selected_suppliers.present?
      sales_quote.selected_suppliers.each do |inquiry_product_id, inquiry_product_supplier_id|
        selected_rows = sales_quote.rows.reject { |r| r.inquiry_product.id == inquiry_product_id.to_i && r.inquiry_product_supplier_id != inquiry_product_supplier_id.to_i }
        rejected_rows = sales_quote.rows.select { |r| r.inquiry_product.id == inquiry_product_id.to_i && r.inquiry_product_supplier_id != inquiry_product_supplier_id.to_i }
        sales_quote.rows.each do |row|
          row.destroy if rejected_rows.include?(row) && row.persisted?
        end
        sales_quote.rows = selected_rows
      end
      sales_quote.rows.each do |row|
        row.unit_selling_price = row.unit_selling_price
        row.converted_unit_selling_price = row.calculated_converted_unit_selling_price
      end
      sales_quote.supplier_rfq_ids = sales_quote.rows.map { |sq_row| sq_row.inquiry_product_supplier.supplier_rfq_id }.compact if sales_quote.id.nil?

      if sales_quote.sent_at.present?
        sales_quote.save_and_sync
        remote_uid = SalesQuote.maximum('remote_uid') + 1
        sales_quote.update_attributes(remote_uid: remote_uid)
        sales_quote.inquiry.update_attributes(quotation_uid: remote_uid)
      else
        sales_quote.save
      end
      supplier_rfqs = SupplierRfq.where(id: sales_quote.supplier_rfq_ids) if sales_quote.supplier_rfq_ids.present?
      if supplier_rfqs.present?
        sales_quote.supplier_rfqs.map { |rfq| SupplierRfqsIndex::SupplierRfq.import([rfq.id])  }
      end
    else
      sales_quote.reload
      sales_quote.inquiry.errors.add(:sales_quote, 'Must have at least one sales quote row')
    end
  end

  attr_reader :sales_quote
end
