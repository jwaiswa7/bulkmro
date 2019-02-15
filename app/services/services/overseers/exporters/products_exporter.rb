class Services::Overseers::Exporters::ProductsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(headers)
    @file_name = 'products'
    super(headers, @file_name)
    @model = Product
    @columns = ['id', 'SKU', 'Name', 'Category', 'Sub Category 1', 'Sub Category 2', 'Brand', 'UOM', 'Hsn/Sac Code' ]
    @columns.each do |column|
      rows.push(column)
    end
  end

  def call
    build_csv
  end

  def build_csv
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(rows)
      model.includes(:category, :brand, :measurement_unit).all.order(created_at: :desc).each do |record|
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
        created_by: (record.created_by.full_name if record.created_by.present?),
        created_at: record.created_at.to_date.to_s

                  )
      end
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
