class Services::Overseers::Finders::BaseFinder < Services::Shared::BaseService
  def initialize(params, current_overseer = nil, paginate: true)
    @search_filters = []
    @range_filters = []
    @paginate = paginate
    @status = params[:status]
    @base_filter = []
    @sort_by = "created_at"
    @sort_order = "desc"

    if params[:columns].present?
      params[:columns].each do |index, column|
        if column[:searchable] && column[:search][:value].present?
          if column[:search][:value].include? "~"
            range_filters << column
          else
            search_filters << column
          end
        end
      end
      if params[:order].values.first["column"].present? && params[:columns][params[:order].values.first["column"]][:name].present? && params[:order].values.first["dir"].present?
        @sort_by = params[:columns][params[:order].values.first["column"]][:name]
        @sort_order = params[:order].values.first["dir"]
      end
    end
    if params[:base_filter_key].present? && params[:base_filter_value].present?
      if params[:base_filter_value].kind_of?(Array)
        # filter_By_array
        @base_filter = filter_by_array(params[:base_filter_key], params[:base_filter_value])
      else
        # filter by value
        @base_filter = filter_by_value(params[:base_filter_key], params[:base_filter_value])
      end
    end

    @query_string = if params[:search].present? && params[:search][:value].present?
      params[:search][:value]
    elsif params[:q].present?
      params[:q]
    elsif params.is_a?(String)
      params
    else
      ""
    end.try(:strip)


    @per = (params[:per] || params[:length] || 20).to_i
    @page = params[:page] || ((params[:start] || 20).to_i / per + 1)
    @current_overseer = current_overseer
  end

  def call_base
    non_paginated_records = if query_string.present?
      perform_query(query_string)
    else
      all_records
    end

    @indexed_records = non_paginated_records.page(page).per(per) if non_paginated_records.present?
    @indexed_records = non_paginated_records if !paginate

#    @records = model_klass.where(:id => indexed_records.pluck(:id)).with_includes if indexed_records.present?
#    @records = order_by_ids(@indexed_records) if indexed_records.present?
    if @indexed_records.size > 0
      @records = model_klass.find_ordered(indexed_records.pluck(:id)).with_includes if @indexed_records.present?
    else
      @records = model_klass.none
    end
  end


  def all_records
    index_klass.all.order(sort_definition)
  end

  def perform_query(query_string)
    index_klass.query(
      query_string: {
          fields: index_klass.fields,
          query: query_string,
          default_operator: "or"
      }
                      )
  end

  def filter_query(indexed_records)
    search_filters.each do |search_filter|
      indexed_records = indexed_records.filter(
        term: {
            :"#{search_filter[:name]}" => search_filter[:search][:value]
        }
                                               ) if search_filter[:search][:value].present? && search_filter[:search][:value] != "null"
    end

    indexed_records
  end

  def range_query(indexed_records)
    range_filters.each do |range_filter|
      range = range_filter[:search][:value].split("~")
      indexed_records = indexed_records.query(
        range: {
            :"#{range_filter[:name]}" => {
                gte: range[0].strip.to_date,
                lte: range[1].strip.to_date
            }
        }
                                              )
    end

    indexed_records
  end

  def sort_definition
    { "#{sort_by}" => "#{sort_order}" }
  end

  def index_klass
    [model_klass.to_s.pluralize, "Index"].join.constantize
  end

  def filter_by_owner(ids)
    {
        bool: {
            should: [
                {
                    terms: { inside_sales_executive: ids },
                },
                {
                    terms: { outside_sales_executive: ids }
                }
            ],
            minimum_should_match: 1,
        },

    }
  end

  def filter_must_exist(key)
    {
        bool: {
            should: [
                {
                    exists: { field: "#{key}" }
                },
            ],
        },
    }
  end

  def filter_by_array(key, vals)
    {
        bool: {
            should: [
                {
                    terms: { "#{key}": vals },
                }
            ]
        },

    }
  end

  def filter_by_value(key, val)
    {
        bool: {
            should: [
                {
                    term: { "#{key}": val },
                },
            ]
        },

    }
  end

  def filter_by_status(only_remote_approved = false, key = nil)
    if only_remote_approved
      {
          bool: {
              should: [
                  {
                      term: { status: SalesOrder.statuses[:Approved] },
                  },
                  {
                      term: { legacy_request_status: SalesOrder.legacy_request_statuses[:Approved] },
                  },
                  {
                      term: { approval_status: "approved" },
                  },
              ],
              minimum_should_match: 2,
          },

      }
    elsif key.present?
      {
          bool: {
              should: [
                  {
                      term: { status: SalesOrder.statuses[key] },
                  },
                  {
                      term: { legacy_request_status: SalesOrder.legacy_request_statuses[key] },
                  },
                  {
                      term: { approval_status: key },
                  },
              ],
              minimum_should_match: 2,
          },
      }
    else
      {
          bool: {
              should: [
                  {
                      term: { legacy_status: "not_legacy" },
                  },
                  {
                      exists: { field: "sent_at" }
                  },
                  {
                      terms: { status: SalesOrder.statuses.except(:'Approved', :'Rejected', :'Canceled').values },
                  },
              ],
              minimum_should_match: 3,
          },
      }
    end
  end

  def aggregate_by_status(key= "statuses",  aggregation_field= "potential_value", status_field)
    {
        "#{key}": {
            terms: {
                field: status_field
            },
            aggs: {
                total_value: {
                    sum: {
                        field: aggregation_field
                    }
                }
            }
        }
    }
  end

  def filter_by_script(condition)
    {
        script: {
            script: condition
        }
    }
  end

  attr_accessor :query_string, :page, :per, :records, :indexed_records, :current_overseer, :search_filters, :range_filters, :paginate, :base_filter, :sort_by, :sort_order
end
