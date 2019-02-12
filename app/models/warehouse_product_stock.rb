class WarehouseProductStock < ApplicationRecord
  belongs_to :product
  belongs_to :warehouse

  pg_search_scope :locate, :against => [], :associated_against => {:warehouse => [:name, :id], :product => [:sku, :name]}, :using => {:tsearch => {:prefix => true}}

  scope :total_qty, -> {sum(:instock)}
end