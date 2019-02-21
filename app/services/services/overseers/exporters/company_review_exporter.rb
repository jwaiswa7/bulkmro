class Services::Overseers::Exporters::CompanyReviewExporter < Services::Overseers::Exporters::BaseExporter
  def initialize
    super
    @model = CompanyReview
    @export_name = 'supplier_review'
    @path = Rails.root.join('tmp', filename)
    @columns = ['serial', 'supplier_id', 'supplier_name', 'rating_submitted_by', 'form', 'rating']
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
        form: company_review.created_by.role,
        rating: company_review.rating
      )
    end
    export = Export.create!(export_type: 60)
    generate_csv(export)
  end
end
