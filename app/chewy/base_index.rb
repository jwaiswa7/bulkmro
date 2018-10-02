class BaseIndex < Chewy::Index
  settings analysis: {
      analyzer: {
          edge_ngram: {
              tokenizer: 'edge_ngram'
          },
          letter: {
              tokenizer: 'letter',
              filter: ['lowercase']
          },
          keyword: {
              tokenizer: 'keyword'
          }
      }
  }, max_result_window: 5000000

  def self.fields
    mappings_hash[:mappings][self.to_s.underscore.split('_').first.singularize.to_sym][:properties].keys
  end
end