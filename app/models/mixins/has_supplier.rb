module Mixins::HasSupplier
  extend ActiveSupport::Concern

  included do
    belongs_to :supplier, -> { acts_as_supplier }, class_name: 'Company', foreign_key: :supplier_id
  end
end