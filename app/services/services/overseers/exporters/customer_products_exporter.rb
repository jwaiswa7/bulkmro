class Services::Overseers::Exporters::CustomerProductsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = CustomerProduct
    @export_name = 'customer_products'
    @path = Rails.root.join('tmp', filename)
    @columns = ['company_name', 'product_name', 'sku', 'customer_price', 'moq', 'tax_code', 'tax_rate', 'measurement_unit', 'brand']
    @company_id = params.first[:company_id]
  end

  def call
    ApplicationExportJob.perform_now('CustomerProductsExporter', @arguments)
  end

  def build_csv
    records = model.where(company: Company.find(company_id)).order(created_at: :desc)
    records.each do |record|
      rows.push(company_name: record.company.to_s,
          product_name: record.to_s,
          sku: record.sku,
          customer_price: record.customer_price,
          moq: is_present(record.moq, 'to_s'),
          tax_code: is_present(record.tax_code, 'code'),
          tax_rate: is_present(record.tax_rate, 'tax_percentage', '%'),
          measurement_unit: is_present(record.measurement_unit, 'name'),
          brand: is_present(record.brand, 'to_s')
      )
    end
    filtered = @ids.present?
    export = Export.create!(export_type: 95, filtered: filtered, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end

  def is_present(check_parameter, get_params_value, symbol = nil)
    if check_parameter.present?
      symbol.present? ? "#{check_parameter.send(get_params_value)} #{symbol}" : "#{check_parameter.send(get_params_value)}"
    else
      ' N / A'
    end
  end
  attr_accessor :company_id
end
