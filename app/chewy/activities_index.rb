class ActivitiesIndex < BaseIndex
  purposes = Activity.purposes
  acitity_types = Activity.activity_types
  define_type Activity.with_includes do
    field :id, type: 'integer'
    field :created_by_id, value: -> (record) { record.created_by.id.to_s if record.created_by.present? }
    field :created_by, value: -> (record) { record.created_by.to_s }, analyzer: 'substring'
    field :account_id, value: -> (record) { record.account.id if record.account.present? }
    field :activity_date, value: -> (record) { record.activity_date }, type: 'date'
    field :account_name, value: -> (record) { record.activity_account.to_s }, analyzer: 'substring'
    field :company_id, value: -> (record) { record.activity_company.id if record.company.present? }
    field :company, value: -> (record) { record.activity_company.to_s }, analyzer: 'substring'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i if record.inquiry.present? }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }
    field :contact_id, value: -> (record) { record.contact.id if record.contact.present? }
    field :contact_name, value: -> (record) { record.contact.to_s }, analyzer: 'substring'
    field :purpose_id, value: -> (record) { purposes[record.purpose] }
    field :purpose, value: -> (record) { record.purpose }, analyzer: 'substring'
    field :activity_type_id, value: -> (record) { acitity_types[record.activity_type] }
    field :activity_type, value: -> (record) { record.activity_type }, analyzer: 'substring'
    field :created_at, type: 'date'
    field :updated_at, type: 'date'
  end
end
