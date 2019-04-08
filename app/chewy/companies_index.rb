class CompaniesIndex < BaseIndex
  businesses = Company.nature_of_businesses
  define_type Company.with_includes do
    field :id, type: 'integer'
    field :account_id, value: -> (record) {record.account_id}
    field :name, value: -> (record) {record.name}, analyzer: 'fuzzy_substring'
    field :account, value: -> (record) {record.account.to_s}, analyzer: 'substring'
    field :addresses, value: -> (record) {record.addresses.size}, type: 'integer'
    field :addresses_string, value: -> (record) {record.addresses.to_s}, analyzer: 'substring'
    field :contacts_string, value: ->(record) {record.default_contact&.name}
    field :contacts, value: -> (record) {record.contacts.size}, type: 'integer'
    field :inquiries, value: -> (record) {record.inquiries.size}, type: 'integer'
    field :pan, value: -> (record) {record.pan.to_s}, analyzer: 'substring'
    field :is_pan_valid, value: -> (record) {record.validate_pan}
    field :is_supplier, value: -> (record) {record.is_supplier?}
    field :is_customer, value: -> (record) {record.is_customer?}
    field :rating, value: -> (record) {record.rating}, type: 'float'
    field :sap_status, value: -> (record) {record.synced?}

    field :nature_of_business_string, value: -> (record) {record.nature_of_business}
    field :nature_of_business, value: -> (record) {businesses[record.nature_of_business]}
    field :purchase_orders_count, value: -> (record) {record.purchase_orders.count}, type: 'integer'
    field :supplied_brands_count, value: -> (record) {record.supplied_brands.uniq.count}, type: 'integer'
    field :supplied_products_count, value: -> (record) {record.supplied_products.uniq.count}, type: 'integer'
    field :supplied_brand_names, value: -> (record) {record.supplied_brands.map(&:name).uniq.join(',').upcase}

    field :created_at, value: -> (record) {record.created_at}, type: 'date'
    field :updated_at, value: -> (record) {record.updated_at}, type: 'date'
  end
end
