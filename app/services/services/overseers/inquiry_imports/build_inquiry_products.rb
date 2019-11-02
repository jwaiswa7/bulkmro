class Services::Overseers::InquiryImports::BuildInquiryProducts < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call
    service = Services::Overseers::InquiryImports::NextSrNo.new(inquiry)

    excel_import.rows.reverse.each do |row|
      if row.failed?
        tax_code = row.metadata['tax_code'].present? ? row.metadata['tax_code'].to_s.gsub('.0', '') : nil
        is_service = row.metadata['is_service'].present? && row.metadata['is_service'].downcase == 'yes' ? true : false
        category = row.metadata['category_id'].present? && row.metadata['category_id'].to_i.to_s.match?(/^[1-9]*/) ? row.metadata['category_id'].to_i : nil
        tax_rate = row.metadata['tax_rate'].present? && row.metadata['tax_rate'].to_f.to_s.match?(/^[1-9]*/) ? row.metadata['tax_rate'].to_f : nil
        if Product.find_by_sku(row['sku']).present?
          row.sku = Services::Resources::Shared::UidGenerator.product_sku(excel_import.rows.map { |r| r['sku'] })
        end
        row.build_inquiry_product(
          inquiry: inquiry,
          import: excel_import,
          sr_no: service.call(row.metadata['sr_no'] || row.metadata['id']),
          product: Product.new(
            inquiry_import_row: row,
            name: row.metadata['name'],
            sku: row.sku,
            mpn: row.metadata['mpn'],
            brand: Brand.find_by_name(row.metadata['brand']).present? && Brand.find_by_name(row.metadata['brand']).is_active ? Brand.find_by_name(row.metadata['brand']) : nil,
            tax_code: tax_code.present? ? TaxCode.where(code: tax_code, is_service: is_service, is_active: true).last : nil,
            tax_rate: tax_rate.present? ? TaxRate.where(tax_percentage: tax_rate).last : nil,
            category: category.present? ? Category.where(id: category, is_service: is_service, is_active: true).last : nil,
            is_service: is_service
          ),
          quantity: row.metadata['quantity'].to_i
        )
      end
    end
  end

  attr_accessor :inquiry, :excel_import
end
