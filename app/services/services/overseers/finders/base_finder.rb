class Services::Overseers::Finders::BaseFinder < Services::Shared::BaseService
  def initialize(params)
    @query = if params[:search].present? && params[:search][:value].present?
               params[:search][:value]
             elsif params[:q].present?
               params[:q]
             elsif params.is_a?(String)
               params
             else
               ''
             end.gsub(/[^0-9A-Za-z]/, '')

    @page = params[:page]
    @per = params[:per] || 20
  end

  def call_base
    @indexed_records = if query.present?
                          index_klass.query(:query_string => {
                               fields: index_klass.fields,
                               query: query,
                               default_operator: 'or'
                           })
                         else
                           index_klass.all.order(:created_at => :desc)
                         end.page(page).per(per)


    @records = model_klass.where(:id => indexed_records.pluck(:id)).with_includes
  end

  def index_klass
    [model_klass.to_s.pluralize, 'Index'].join.constantize
  end

  attr_accessor :query, :page, :per, :records, :indexed_records
end