class Services::Shared::Snippets < Services::Shared::BaseService

  def delete_all_inquiries
    SalesOrderRow.delete_all
    SalesOrderApproval.all.delete_all
    SalesOrderConfirmation.delete_all
    SalesOrderRejection.delete_all
    SalesOrderApproval.delete_all
    SalesOrder.delete_all
    SalesQuoteRow.delete_all
    SalesQuote.delete_all
    InquiryProductSupplier.delete_all
    InquiryImportRow.delete_all
    InquiryImport.delete_all
    InquiryProduct.delete_all
    ActivityOverseer.delete_all
    Activity.delete_all
    InquiryComment.delete_all
    Inquiry.delete_all
  end

  def delete_inquiry_products
    SalesQuoteRow.delete_all
    SalesQuote.delete_all
    InquiryProductSupplier.delete_all
    InquiryProduct.delete_all
  end

  def run_inquiry_details_migration
    PaperTrail.request(enabled: false) do
      Services::Shared::Migrations::Migrations.new(['activities']).call
    end
  end

  def approve_products
    PaperTrail.request(enabled: false) do
      Product.all.not_approved.each do |product|
        product.create_approval(:comment => product.comments.create!(:overseer => Overseer.default, message: 'Legacy product, being preapproved'), :overseer => Overseer.default) if product.approval.blank?
      end
    end
  end

  def add_column_dirty
    ActiveRecord::Base.connection.execute('ALTER TABLE products ADD COLUMN weight DECIMAL')
  end

  def change_column_type_db
    ActiveRecord::Base.connection.execute('ALTER TABLE inquiries ALTER COLUMN inquiry_number TYPE BIGINT USING inquiry_number::bigint')
  end

  def fix_product_brands
    PaperTrail.request(enabled: false) do
      service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv')
      service.loop(nil) do |x|
        next if x.get_column('entity_id').to_i < 677812
        brand = Brand.where("legacy_metadata->>'option_id' = ?", x.get_column('product_brand')).first
        product = Product.find_by_legacy_id(x.get_column('entity_id'))
        product.update_attributes(:brand => brand) if product.present?
      end
    end
  end


  def activities_migration_fix
    Activity.where(:created_by => nil).each do |activity|
      activity_overseer = activity.activity_overseers.first

      ActiveRecord::Base.transaction do
        activity.update_attributes!(:overseer => activity_overseer.overseer)
        activity_overseer.destroy!
      end if activity_overseer.present?
    end
  end

  def activities_migration_fix_2
    service = Services::Shared::Spreadsheets::CsvImporter.new('activity_reports.csv')
    service.loop(nil) do |x|
      overseer_legacy_id = x.get_column('overseer_legacy_id')
      overseer = Overseer.find_by_legacy_id(overseer_legacy_id)
      activity = Activity.where(legacy_id: x.get_column('legacy_id')).first
      activity.update_attributes(:created_by => overseer, :updated_by => overseer) if activity.present?
    end
  end

  def product_brands_fix
    service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv')
    service.loop(nil) do |x|
      brand = Brand.where("legacy_metadata->>'option_id' = ?", x.get_column('product_brand')).first
      product = Product.find_by_legacy_id(x.get_column('entity_id'))
      product.update_attributes(:brand => brand)
    end
  end

end