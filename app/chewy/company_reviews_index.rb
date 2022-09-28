class CompanyReviewsIndex < BaseIndex
  survey_types = CompanyReview.survey_types
  define_type CompanyReview.where.not(rating: nil).with_includes do
    field :id, type: 'integer'
    field :company_id, value: -> (record) { record.company_id }
    field :company_name, value: -> (record) { record.company.to_s if record.company_id.present?}, analyzer: 'substring'
    field :survey_type_id, value: -> (record) { survey_types[record.survey_type] if record.survey_type.present? }
    field :survey_type, value: -> (record) { record.survey_type if record.survey_type.present? }
    field :created_by_id, value: -> (record) { record.created_by_id if record.created_by_id.present? }
    field :created_by_string, value: -> (record) { record.created_by.to_s if record.created_by_id.present? }
    field :updated_by_id, value: -> (record) { record.updated_by_id if record.updated_by_id.present? }
    field :updated_by_string, value: -> (record) { record.updated_by.to_s if record.updated_by_id.present? }
    field :created_at, value: -> (record) { record.created_at }, type: 'date'
    field :updated_at, value: -> (record) { record.updated_at }, type: 'date'
  end
end
