class BaseIndex < Chewy::Index
  settings(
    analysis: {
        "filter": {
            "whitespace_and_special_character_removal": {
                "type": "pattern_replace",
                "pattern": "[^A-Za-z0-9]+",
                "replacement": ""
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
                filter: %w(lowercase whitespace_and_special_character_removal)
            },
            substring: {
                tokenizer: 'substring',
                filter: ['lowercase']
            },
            sku_substring: {
                tokenizer: 'sku_substring',
                filter: ['lowercase']
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
            }
        }
    },
    max_result_window: 5000000,
    "number_of_replicas": '0',
    "number_of_shards": '1'
  )

  def self.fields
    mappings_hash[:mappings][self.to_s.underscore.split('_').first.singularize.to_sym][:properties].keys - [:created_at, :updated_at, :id, :inquiry_number]
  end
end
