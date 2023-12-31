class Services::Overseers::Exporters::ProductsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)

    @model = Product
    @export_name = 'products'
    @path = Rails.root.join('tmp', filename)
    @columns = ['id', 'SKU', 'Name', 'Category', 'Sub Category 1', 'Sub Category 2', 'Brand', 'UOM', 'Hsn/Sac Code', 'MPN', 'Tax Percentage', 'Is Service', 'Is Active', 'SAP Synced', 'Created by', 'Created At' ]
  end

  def call
    perform_export_later('ProductsExporter', @arguments)
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name,true,@export_time).deliver_now
    if @ids.present?
      records = model.where(id: @ids)
    else
      records = model
    end
    # records.each do |record|
    @export = Export.create!(export_type: 5, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    records.includes(:category, :brand, :measurement_unit).all.order(created_at: :desc).find_each(batch_size: 100) do |record|
      rows.push(
        id: record.id,
        sku: record.sku,
        name: record.name,
        category: (record.category.ancestors_to_s.first if record.category.present? && record.category.ancestors_to_s.first.present?),
        sub_category_1: (record.category.ancestors_to_s.second if record.category.present? && record.category.ancestors_to_s.second.present?),
        sub_category_2: (record.category.ancestors_to_s.third if record.category.present? && record.category.ancestors_to_s.third.present?),
        brand: (record.brand.name if record.brand.present?),
        measurement_unit: (record.measurement_unit.name if record.measurement_unit.present? && record.measurement_unit.name.present?),
        tax_code: (record.best_tax_code.chapter if record.best_tax_code.present?),
        mpn: record.mpn,
        tax_rate: (record.tax_rate.tax_percentage.to_f if record.tax_rate.present?),
        is_service: record.is_service,
        is_active: record.is_active,
        sap_synced: record.is_active,
        created_by: (record.created_by || (record.inquiry_import_row.inquiry.created_by if record.inquiry_import_row)).try(:name) || '-',
        created_at: record.created_at.to_date.to_s

                )
    end
    # filtered = @ids.present?
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
