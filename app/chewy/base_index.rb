class BaseIndex < Chewy::Index
  settings analysis: {
      analyzer: {
          edge_ngram: {
              tokenizer: 'edge_ngram',
              filter: ['lowercase']
          },
          letter: {
              tokenizer: 'letter',
              filter: ['lowercase']
          },
          keyword: {
              tokenizer: 'keyword'
          },
          sortable: {
              tokenizer: 'keyword'
          },
      }
  }, max_result_window: 5000000

  def self.fields
    mappings_hash[:mappings][self.to_s.underscore.split('_').first.singularize.to_sym][:properties].keys - [:created_at, :updated_at, :id, :inquiry_number]
  end
end