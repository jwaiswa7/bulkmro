class Services::Overseers::Exporters::CompaniesExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Company
    @export_name = 'companies'
    @path = Rails.root.join('tmp', filename)
    @columns = ['name', 'company_alias', 'industry', 'remote_uid', 'state_name', 'company_contact', 'payment_option', 'inside_sales_owner', 'outside_sales_owner', 'sales_manager', 'site', 'phone', 'mobile', 'email', 'pan', 'tan', 'company_type', 'nature_of_business', 'credit_limit', 'is_msme', 'tax_identifier', 'created_at']
  end

  def call
    perform_export_later('CompaniesExporter', @arguments)
  end

  def build_csv
    if @ids.present?
      records = model.where(id: @ids).order(created_at: :desc)
    else
      records = model.includes({ addresses: :state }, :company_contacts, :inside_sales_owner, :outside_sales_owner, :industry, :account).all.order(created_at: :desc)
    end
    records.each do |record|
    rows.push(
      name: record.name,
      comapny_alias: record.account.name,
      industry: (record.industry.name if record.industry.present?),
      remote_uid: record.remote_uid,
      state_name: (record.default_billing_address.present? ? record.default_billing_address.try(:state).try(:name) : record.addresses.first.try(:state).try(:name)),
      company_contact: (record.default_company_contact.contact.full_name if record.default_company_contact.present?),
      payment_option: (record.default_payment_option.name if record.default_payment_option.present?),
      inside_sales_owner: (record.inside_sales_owner.try(:full_name) if record.inside_sales_owner.present?),
      outside_sales_owner: (record.outside_sales_owner.try(:full_name) if record.outside_sales_owner.present?),
      sales_manager: (record.sales_manager.full_name if record.sales_manager.present?),
      site: record.site,
      phone: record.phone,
      mobile: record.mobile,
      email: record.email,
      pan: record.pan,
      tan: record.tan,
      company_type: record.company_type,
      nature_of_business: record.nature_of_business,
      credit_limit: record.credit_limit,
      is_msme: record.is_msme,
      tax_identifier: record.tax_identifier,
      created_at: record.created_at.to_date.to_s
    )
  end
    filtered = @ids.present?
    export = Export.create!(export_type: 10, filtered: filtered, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
