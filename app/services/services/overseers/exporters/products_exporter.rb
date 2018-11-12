class Services::Overseers::Exporters::ProductsExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = ['id', 'SKU', 'Name', 'Category', 'Brand']
    @model = Product
  end

  def call
    model.includes(:category, :brand).all.each do |record|
      rows.push({
                    :id => record.id,
                    :sku => record.sku,
                    :name => record.name,
                    :category => (record.category.name if record.category.present?),
                    :brand => (record.brand.name if record.brand.present?)
                })
    end

    generate_csv
  end
end