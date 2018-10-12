class Services::Overseers::Finders::BaseFinder < Services::Shared::BaseService
  def initialize(params)
    @query_string = if params[:search].present? && params[:search][:value].present?
               params[:search][:value]
             elsif params[:q].present?
               params[:q]
             elsif params.is_a?(String)
               params
             else
               ''
             end

    @per = (params[:per] || params[:length] || 20).to_i
    @page = params[:page] || ((params[:start] || 20).to_i / per + 1)
  end

  def call_base
    @indexed_records = if query_string.present?
                         perform_query(query_string)
                       else
                         index_klass.all.order(sort_definition)
                       end.page(page).per(per).order(sort_definition)

    @records = model_klass.where(:id => indexed_records.pluck(:id)).with_includes
  end

  def index_klass
    [model_klass.to_s.pluralize, 'Index'].join.constantize
  end

  def perform_query(query_string)
    index_klass.query({
        :query_string => {
            fields: index_klass.fields,
            query: query_string,
            default_operator: 'or'
        }
    })
  end

  def sort_definition
    # {:created_at => :desc}
  end

  attr_accessor :query_string, :page, :per, :records, :indexed_records
end