class Services::Overseers::Finders::BaseFinder < Services::Shared::BaseService
  def initialize(params, current_overseer = nil)
    @search_filters = []
    if params[:columns].present?
      params[:columns].each do | index, column |
        if column[:searchable] && column[:search][:value].present?
          @search_filters << column
        end
      end
    end

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
    @current_overseer = current_overseer
  end

  def call_base
    @indexed_records = if query_string.present?
                         perform_query(query_string)
                       else
                         all_records
                       end.page(page).per(per)

    @records = model_klass.where(:id => indexed_records.pluck(:id)).with_includes
  end


  def all_records
    index_klass.all.order(sort_definition)
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

  def filter_query(indexed_records)
    search_filters.each do |search_filter|
      indexed_records = indexed_records.filter({
             term: {
                 "#{search_filter[:name]}": search_filter[:search][:value]
             }
         })
    end
    indexed_records
  end

  def sort_definition
    {:created_at => :desc}
  end

  def index_klass
    [model_klass.to_s.pluralize, 'Index'].join.constantize
  end

<<<<<<< HEAD
  attr_accessor :query_string, :page, :per, :records, :indexed_records, :overseer_ids, :search_filters
=======
  attr_accessor :query_string, :page, :per, :records, :indexed_records, :current_overseer
>>>>>>> master
end