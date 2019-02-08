# frozen_string_literal: true

class ProductSupplier < ApplicationRecord
  belongs_to :supplier, class_name: "Company", foreign_key: :supplier_id
  belongs_to :product

  validates_uniqueness_of :product, scope: :supplier
end
