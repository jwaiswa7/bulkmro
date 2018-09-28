class Services::Overseers::Inquiries::Finder < Services::Shared::BaseService

  def initialize(params)
    @query = if params[:search].present? && params[:search][:value].present?
           params[:search][:value]
         elsif params[:q].present?
           params[:q]
             end

    @page = params[:page]
  end

  def call
    run
  end

  def run
    @indexed_inquiries = if query.present?
                           InquiryIndex.query(:query_string => {
                               fields: InquiryIndex.fields,
                               query: query,
                               default_operator: 'or'
                           })
                         else
                           InquiryIndex.all
                         end.page(page).per(20)

    @inquiries = Inquiry.where(:id => indexed_inquiries.pluck(:id)).with_includes
  end

  attr_accessor :query, :page, :inquiries, :indexed_inquiries
end