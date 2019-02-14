# frozen_string_literal: true

class Services::Overseers::Finders::Warehouses < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    Warehouse
  end

  def perform_query(query)
    query = query[0, 35]

    index_klass.query(
      multi_match: {
          query: query,
          operator: 'and',
          fields: %w[name^3 state_name remote_uid gst location],
          minimum_should_match: '100%'
      }
                      ).order(sort_definition)
  end

  def sort_definition
    { created_at: :asc }
  end
end
