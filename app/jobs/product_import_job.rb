# frozen_string_literal: true

class ProductImportJob < ActiveJob::Base
  queue_as :default

  def perform(product_import_id)
    Services::Overseers::Products::Importer.new(product_import_id).call
  end
end
  