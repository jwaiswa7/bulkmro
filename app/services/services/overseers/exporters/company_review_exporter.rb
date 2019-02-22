class Services::Overseers::Exporters::CompanyReviewExporter < Services::Overseers::Exporters::BaseExporter
  def initialize
    super
    @model = CompanyReview
    @export_name = 'supplier_review'
    @path = Rails.root.join('tmp', filename)
    @columns = ['serial', 'supplier_id', 'supplier_name', 'rating_submitted_by', 'review_type', 'rating', 'document']
  end
  def call
    perform_export_later('CompanyReviewExporter')
  end

  def build_csv
    model.includes(:company).each_with_index do |company_review, index|
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
    export = Export.create!(export_type: 70)
    generate_csv(export)
  end
end
