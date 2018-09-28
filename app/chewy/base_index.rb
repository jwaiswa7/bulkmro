class BaseIndex < Chewy::Index
  settings analysis: {
      analyzer: {
          edge_ngram: {
              tokenizer: 'edge_ngram'
          },
          letter: {
              tokenizer: 'letter',
              filter: ['lowercase']
          }
      }
  }

  def self.fields
    mappings_hash[:mappings][self.to_s.underscore.split('_').first.singularize.to_sym][:properties].keys
  end
end