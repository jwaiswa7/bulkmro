# frozen_string_literal: true

class BulkProductUploadJob < ActiveJob::Base
	queue_as :default

      # If record is no longer available, it is safe to ignore
      discard_on ActiveJob::DeserializationError

      discard_on ActiveRecord::RecordNotFound

	def perform(file_path, overseer)
      doc = SimpleXlsxReader.open(file_path)
      rows = doc.sheets.first.rows
      products_array = rows.drop(1).map {|row| Product.new(name: row[1], measurement_unit_id: row[2], brand_id: row[3], tax_code_id: row[5], tax_rate_id: row[6], is_service: row[7], category_id: row[8], created_by: overseer)}
      Product.import products_array
	end
end
