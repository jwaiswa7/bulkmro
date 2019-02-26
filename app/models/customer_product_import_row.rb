# frozen_string_literal: true

class CustomerProductImportRow < ApplicationRecord
  belongs_to :import, class_name: 'CustomerProductImport', foreign_key: :customer_product_import_id
end
