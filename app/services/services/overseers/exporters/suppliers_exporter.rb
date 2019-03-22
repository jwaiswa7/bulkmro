class Services::Overseers::Exporters::SuppliersExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Company.acts_as_supplier
    @export_name = 'suppliers'
    @path = Rails.root.join('tmp', filename)
    @columns = ['name', 'comapny_alias', 'supplier_type', 'address', 'contact', 'rating', 'no_of_purchase_orders', 'no_of_supplied_brands', 'no_of_supplied_products', 'brands', 'Created']
  end

  def call
    perform_export_later('SuppliersExporter', @arguments)
  end

  def build_csv
    if @ids.present?
      records = model.where(id: @ids).order(created_at: :desc)
    else
      records = model.includes({ addresses: :state }, :company_contacts, :account).all.order(created_at: :desc)
    end
    records.each do |record|
      rows.push(
        name: record.name,
        comapny_alias: record.account.name,
        supplier_type: record.nature_of_business&.titleize,
        address: record.billing_address.to_s,
        contact: record.default_contact&.name,
        rating: record.rating,
        purchase_orders: record.purchase_orders.count,
        supplied_brands: record.supplied_brands&.uniq&.count,
        supplied_products: record.supplied_products&.uniq&.count,
        brands: record.supplied_brands.map(&:name)&.uniq&.join(', ').upcase,
        created: record.created_at.to_date.to_s
      )
    end
    filtered = @ids.present?
    export = Export.create!(export_type: 65, filtered: filtered, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
