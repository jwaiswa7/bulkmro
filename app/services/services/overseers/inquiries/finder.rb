class Services::Overseers::Inquiries::Finder < Services::Shared::BaseService

  def initialize(params)
    @params = params
  end

  def call
    run
  end

  def run
    @indexed_inquiries = if params[:search].present? && params[:search][:value].present?
      InquiryIndex.query(:query_string => {
          fields: InquiryIndex.fields,
          query: params[:search][:value],
          default_operator: 'or'
      })
    else
      InquiryIndex.all
    end.page(params[:page]).per(20)

    @inquiries = Inquiry.where(:id => indexed_inquiries.pluck(:id)).with_includes
  end

  attr_accessor :params, :inquiries, :indexed_inquiries
end