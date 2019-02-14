# frozen_string_literal: true

class Services::Customers::Finders::Products < Services::Customers::Finders::BaseFinder
  def call
    call_base
  end

  def all_records
    indexed_records = if current_contact.present?
      super.filter(filter_by_array('id', current_contact.account.products.approved.ids))
    else
      super
    end
    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records = filter_by_images(indexed_records)

    indexed_records
  end

  def model_klass
    Product
  end

  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query(multi_match: { query: query, operator: 'and', fields: %w[sku^3 sku_edge has_images name approved brand category], minimum_should_match: '100%' }).order(sort_definition)

    if current_contact.present?
      indexed_records = indexed_records.filter(filter_by_array('id', current_contact.account.products.approved.ids))
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records = filter_by_images(indexed_records)

    indexed_records
  end

  def filter_by_images(indexed_records)
    indexed_records = indexed_records.filter(
      term: { "has_images": true },
                                             )

    indexed_records
  end
end
