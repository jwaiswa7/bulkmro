class Services::Customers::Finders::BaseFinder < Services::Shared::BaseService
  def initialize(params, current_contact = nil, current_company = nil)
    @search_filters = []
    @range_filters = []
    @custom_filters =  params[:custom_filters]

    if params[:columns].present?
      params[:columns].each do |index, column|
        if column[:searchable] && column[:search][:value].present?
          if column[:search][:value].include? '~'
            range_filters << column
          else
            search_filters << column
          end
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
    end.strip

    @per = (params[:per] || params[:length] || 20).to_i
    @page = params[:page] || ((params[:start] || 20).to_i / per + 1)
    @current_contact = current_contact
    @current_company = current_company
  end

  def call_base
    non_paginated_records = if query_string.present?
      perform_query(query_string)
    else
      all_records
    end

    @indexed_records = non_paginated_records.page(page).per(per) if non_paginated_records.present?
    @records = model_klass.where(id: indexed_records.pluck(:id)).with_includes if indexed_records.present?
  end


  def all_records
    index_klass.all.order(sort_definition)
  end

  def perform_query(query_string)
    index_klass.query(
      query_string: {
          fields: index_klass.fields,
          query: query_string,
          default_operator: 'or'
      }
                      )
  end

  def filter_query(indexed_records)
    search_filters.each do |search_filter|
      indexed_records = indexed_records.filter(
        term: {
            :"#{search_filter[:name]}" => search_filter[:search][:value]
        }
                                               ) if search_filter[:search][:value].present? && search_filter[:search][:value] != 'null'
    end

    indexed_records
  end

  def range_query(indexed_records)
    range_filters.each do |range_filter|
      range = range_filter[:search][:value].split('~')
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
    { created_at: :desc }
  end

  def index_klass
    [model_klass.to_s.pluralize, 'Index'].join.constantize
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

  def filter_by_status(only_remote_approved: false)
    if only_remote_approved
      {
          bool: {
              should: [
                  {
                      term: { status: Inquiry.statuses[:Approved] },
                  },
              ],
          },

      }
    else
      {
          bool: {
              should: [
                  {
                      terms: { status: Inquiry.statuses.except(:'SO Rejected by Sales Manager', :'Rejected by Accounts', :'Regret', :'Order Lost').values },
                  },
              ],
          },
      }
    end
  end


  attr_accessor :query_string, :page, :per, :records, :indexed_records, :current_contact, :current_company, :search_filters, :range_filters
end
