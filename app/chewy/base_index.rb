class BaseIndex < Chewy::Index
  settings analysis: {
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
          substring_analyzer: {
              tokenizer: 'substring_tokenizer',
              filter: ['lowercase']
          }
      },
      tokenizer: {
          substring_tokenizer: {
              type: 'edge_ngram',
              min_gram: 2,
              max_gram: 7,
              token_chars:['letter', 'digit']
          }
      }
  }, max_result_window: 5000000

  def self.fields
    mappings_hash[:mappings][self.to_s.underscore.split('_').first.singularize.to_sym][:properties].keys - [:created_at, :updated_at, :id, :inquiry_number]
  end
end
