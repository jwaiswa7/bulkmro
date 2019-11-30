class Services::Overseers::Exporters::CompanyReviewExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = CompanyReview
    @export_name = 'supplier_review'
    @path = Rails.root.join('tmp', filename)
    @columns = ['serial', 'supplier_id', 'supplier_name', 'rating_submitted_by', 'review_type', 'rating', 'document']
    @export.update_attributes(export_type: 60, status: 'Enqueued')
  end
  def call
    perform_export_later('CompanyReviewExporter', @arguments)
  end

  def build_csv
    if @ids.present?
      records = model.where(id: @ids).order(created_at: :desc)
    else
      records = model.where.not(rating: nil).includes(:company)
    end
    @export.update_attributes(status: 'Processing')
    records.each_with_index do |company_review, index|
      rows.push(
        serial: index + 1,
        supplier_id: company_review.company_id,
        supplier_name: company_review.company.name,
        rating_submitted_by: company_review.created_by.name,
        review_type: company_review.survey_type,
        rating: company_review.rating || 0,
        document: company_review.rateable_type + "[#{company_review.rateable_id}]"
      )
    end
    # filtered = @ids.present?
    # export = Export.create!(export_type: 60, filtered: filtered, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
