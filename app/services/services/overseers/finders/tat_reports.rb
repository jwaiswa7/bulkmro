class Services::Overseers::Finders::TatReports < Services::Overseers::Finders::BaseFinder
  def call
    call_base
  end

  def model_klass
    InquiryMappingTat
  end

  def all_records
    indexed_records = index_klass.limit(model_klass.count).order(sort_definition)

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    indexed_records = aggregation_tat_report(indexed_records)
    indexed_records
  end

  def perform_query(query)
    query = query[0, 35]

    indexed_records = index_klass.query(
      multi_match: {
          query: query,
          operator: 'and',
          fields: %w[inquiry_number_string inside_sales_owner],
          minimum_should_match: '100%'
      }
    )
    if @base_filter.present?
      indexed_records = indexed_records.filter(@base_filter)
    end

    if search_filters.present?
      indexed_records = filter_query(indexed_records)
    end

    if range_filters.present?
      indexed_records = range_query(indexed_records)
    end

    indexed_records = aggregation_tat_report(indexed_records)
    indexed_records
  end

  def aggregation_tat_report(indexed_records)
    date_range = {from: '01-01-2019', to: Date.today.strftime('%d-%m-%Y'), key: 'custom-range'}
    indexed_records = indexed_records.aggregations(
      'tat_by_sales_owner': {
          date_range: {
              field: 'created_at',
              format: 'dd-MM-yyy',
              ranges: [
                  date_range
              ],
              keyed: true
          },

          aggs: {
              'inquiry_mapping_tats': {
                  'terms': {'field': 'inside_sales_owner_id', size: 500},
                  aggs: {
                      new_inquiry: {
                          sum: {
                              field: 'status_new_inquiry'
                          }
                      },
                      acknowledgment_mail: {
                          sum: {
                              field: 'status_acknowledgment_mail'
                          }
                      },
                      cross_reference: {
                          sum: {
                              field: 'status_cross_reference'
                          }
                      },
                      preparing_quotation: {
                          sum: {
                              field: 'status_preparing_quotation'
                          }
                      },
                      quotation_sent: {
                          sum: {
                              field: 'status_quotation_sent'
                          }
                      },
                      draft_so_appr_by_sales_manager: {
                          sum: {
                              field: 'status_draft_so_appr_by_sales_manager'
                          }
                      },
                      so_reject_by_sales_manager: {
                          sum: {
                              field: 'status_so_reject_by_sales_manager'
                          }
                      },
                      so_draft_pending_acct_approval: {
                          sum: {
                              field: 'status_so_draft_pending_acct_approval'
                          }
                      },
                      rejected_by_accounts: {
                          sum: {
                              field: 'status_rejected_by_accounts'
                          }
                      },
                      hold_by_accounts: {
                          sum: {
                              field: 'status_hold_by_accounts'
                          }
                      },
                      order_won: {
                          sum: {
                              field: 'status_order_won'
                          }
                      },
                      order_lost: {
                          sum: {
                              field: 'status_order_lost'
                          }
                      },
                      regret: {
                          sum: {
                              field: 'status_regret'
                          }
                      }
                  }
              }
          }
      }
    )
    indexed_records
  end
end