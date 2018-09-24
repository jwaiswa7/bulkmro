module Mixins::HasSupplier
  extend ActiveSupport::Concern

  included do
    belongs_to :supplier, -> { where(is_supplier: true) }, class_name: 'Company', foreign_key: :supplier_id
  end
end