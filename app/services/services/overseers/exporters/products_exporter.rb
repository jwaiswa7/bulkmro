class Services::Overseers::Exporters::ProductsExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = ['id', 'SKU', 'Name', 'Category','Sub Category 1', 'Sub Category 2','Brand']
    @model = Product
  end

  def call
    model.includes(:category, :brand).all.each do |record|
      rows.push({
                    :id => record.id,
                    :sku => record.sku,
                    :name => record.name,
                    :category => (record.category.ancestors_to_s.first if record.category.present? && record.category.ancestors_to_s.first.present?),
                    :sub_category_1 => (record.category.ancestors_to_s.second if record.category.present? && record.category.ancestors_to_s.second.present?),
                    :sub_category_2 => (record.category.ancestors_to_s.third if record.category.present? && record.category.ancestors_to_s.third.present?),


                    :brand => (record.brand.name if record.brand.present?)
                })
    end

    generate_csv
  end
end