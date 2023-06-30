# frozen_string_literal: true

class ProductImportJob < ActiveJob::Base
  queue_as :default

  # If record is no longer available, it is safe to ignore
  discard_on ActiveJob::DeserializationError

  discard_on ActiveRecord::RecordNotFound

  def perform(product_import_id)
    Services::Overseers::Products::Importer.new(product_import_id).call
  end
end
  