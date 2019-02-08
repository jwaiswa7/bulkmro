# frozen_string_literal: true

class Services::Overseers::Finders::Overseers < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    Overseer
  end

  def perform_query(query)
    query = query[0, 35]

    index_klass.query(
      multi_match: {
          query: query,
          operator: "and",
          fields: %w[firstname^3 lastname^3 role],
          minimum_should_match: "100%"
      }
                      ).order(sort_definition)
  end

  def sort_definition
    { created_at: :asc }
  end
end
