class BaseIndex < Chewy::Index
  settings(
    analysis: {
        filter: {
            replace_and: {
                type: 'pattern_replace',
                pattern: '(\s)+and(\s)',
                replacement: ''
            },
            whitespace_and_special_character_removal: {
                type: 'pattern_replace',
                pattern: '[^A-Za-z0-9]+',
                replacement: ''
            },
            "autocomplete_filter": {
                type: 'edge_ngram',
                min_gram: 1,
                max_gram: 20
            }
        },
        analyzer: {
            edge_ngram: {
                tokenizer: 'edge_ngram',
            },
            letter: {
                tokenizer: 'letter',
                filter: ['lowercase']
            },
            keyword: {
                tokenizer: 'keyword',
                filter: ['lowercase']
            },
            fuzzy_substring: {
                tokenizer: 'fuzzy_substring',
                filter: %w(replace_and lowercase whitespace_and_special_character_removal)
            },
            substring: {
                tokenizer: 'substring',
                filter: ['lowercase']
            },
            sku_substring: {
                tokenizer: 'sku_substring',
                filter: ['lowercase']
            },
            keyword_analyzer: {
                filter: ['lowercase', 'asciifolding', 'trim'],
                char_filter: [],
                type: 'custom',
                tokenizer: 'keyword'
            },
            edge_ngram_analyzer: {
                filter: [
                    'lowercase'
                ],
                tokenizer: 'edge_ngram_tokenizer'
            },
            edge_ngram_search_analyzer: {
                tokenizer: 'lowercase'
            },
            autocomplete: {
                type: 'custom',
                tokenizer: 'standard',
                filter: ['lowercase', 'autocomplete_filter']
            }
        },
        tokenizer: {
            fuzzy_substring: {
                type: 'ngram',
                min_gram: 1,
                max_gram: 30,
                token_chars: %w(letter digit whitespace punctuation symbol)
            },
            substring: {
                type: 'ngram',
                min_gram: 1,
                max_gram: 30,
                token_chars: %w(letter digit whitespace punctuation symbol)
            },
            sku_substring: {
                type: 'edge_ngram',
                min_gram: 2,
                max_gram: 7,
                token_chars: %w(letter digit)
            },
            edge_ngram_tokenizer: {
                type: 'edge_ngram',
                min_gram: 2,
                max_gram: 5,
                token_chars: [
                    'letter'
                ]
            }
        }
    },
    max_result_window: 5000000,
    'number_of_replicas': '1',
    'number_of_shards': '1',
    max_ngram_diff: 30,
  )

  def self.fields
    mappings_hash[:mappings][self.to_s.underscore.split('_').first.singularize.to_sym][:properties].keys - [:created_at, :updated_at, :id, :inquiry_number]
  end
end


# ActivitiesIndex.import
# AddressesIndex.import
# ArInvoiceRequestsIndex.import
# BanksIndex.import
# BibleUploadsIndex.import
# CallbackRequestsIndex.import
# CompaniesIndex.import
# CompanyBanksIndex.import
# CompanyReportsIndex.import
# CompanyReviewsIndex.import
# ContactsIndex.import
# CreditNotesIndex.import
# CustomerOrderStatusReportIndex.import
# CustomerProductsIndex.import
# DeliveryChallansIndex.import
# IfscCodesIndex.import
# InquiriesIndex.import
# InquiriesPerOrderIndex.import
# InquiryMappingTatsIndex.import
# InvoiceRequestsIndex.import
# InwardDispatchesIndex.import
# KraReportVarientsIndex.import
# KraReportsIndex.import
# LogisticsScorecardsIndex.import
# NewCompanyReportsIndex.import
# OutwardDispatchesIndex.import
# OverseersIndex.import
# PaymentRequestsIndex.import
# ProductsIndex.import
# PurchaseOrdersIndex.import
# RemoteRequestsIndex.import
# SalesInvoicesIndex.import
# SalesOrdersIndex.import
# SalesOrdersWithCancelIndex.import
# SalesQuotesIndex.import
# SalesReceiptsIndex.import
# SalesShipmentsIndex.import
# SuggestionsIndex.import
# SupplierProductsIndex.import
# SupplierRfqsIndex.import
# TaxCodesIndex.import