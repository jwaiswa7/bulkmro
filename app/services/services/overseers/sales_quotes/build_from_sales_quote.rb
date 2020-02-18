class Services::Overseers::SalesQuotes::BuildFromSalesQuote < Services::Shared::BaseService
  def initialize(old_sales_quote, overseer, selected_inquiry_product_suppliers)
    @old_sales_quote = old_sales_quote
    @overseer = overseer
    @selected_inquiry_product_suppliers = selected_inquiry_product_suppliers.map{ |x| x.to_i} if selected_inquiry_product_suppliers.present?
  end

  def call
    @sales_quote = old_sales_quote.deep_clone include: :rows

    sales_quote.assign_attributes(overseer: overseer)
    sales_quote.assign_attributes(parent_id: old_sales_quote.id)
    sales_quote.assign_attributes(sent_at: nil)
    if @selected_inquiry_product_suppliers.present?
      sales_quote.rows = []
    else
      sales_quote.rows.each do |row|
        row.assign_attributes(overseer: overseer)
        row.assign_attributes(sales_quote_id: old_sales_quote.id)
      end
    end

    sales_quote.inquiry.inquiry_products.each do |inquiry_product|
      all_inquiry_product_suppliers = selected_inquiry_product_suppliers.present? ? inquiry_product.inquiry_product_suppliers.where(id: selected_inquiry_product_suppliers) : inquiry_product.inquiry_product_suppliers
      if all_inquiry_product_suppliers.present?
        all_inquiry_product_suppliers.each do |inquiry_product_supplier|
          if selected_inquiry_product_suppliers.present?
            if selected_inquiry_product_suppliers.include?(inquiry_product_supplier.id)
              if sales_quote.rows.present?
                if sales_quote.rows.select { |r| r.inquiry_product_supplier == inquiry_product_supplier }.blank?
                  sales_quote.rows.build(
                      inquiry_product_supplier: inquiry_product_supplier,
                      tax_code: inquiry_product_supplier.product.best_tax_code,
                      measurement_unit: inquiry_product.product.measurement_unit
                  )
                end
              else
                sales_quote.rows.build(
                    inquiry_product_supplier: inquiry_product_supplier,
                    tax_code: inquiry_product_supplier.product.best_tax_code,
                    measurement_unit: inquiry_product.product.measurement_unit
                )
              end
            end
          end
        end
      end
    end
    sales_quote
  end

  attr_reader :old_sales_quote, :overseer, :sales_quote, :selected_inquiry_product_suppliers
end
