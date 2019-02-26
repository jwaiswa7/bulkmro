class ActivitiesIndex < BaseIndex
  purposes = Activity.purposes
  define_type Activity.with_includes do
    field :id
    field :created_by_id, value: -> (record) { record.created_by_id }, analyzer: 'substring'
    field :account_id, value: -> (record) { record.account_id if record.account_id.present?}
    field :company_id, value: -> (record) { record.company_id if record.company_id.present? }
    field :contact_id, value: -> (record) { record.contact_id if record.contact_id.present? }
    field :purpose, value: -> (record)  { purposes[record.purpose] if record.purpose.present? }
    field :activity_report, value: -> (record) { record.activity_date if record.activity_date.present? },type: 'date'
    field :created_at, type: 'date'
  end
end