# frozen_string_literal: true

class GenerateCatalogJob < ActiveJob::Base
	queue_as :default

	def perform(company_id, overseer_id)
		puts "Job for Company - #{company_id} Start"
		service = Services::Overseers::CustomerProductsCatalog::CatalogGenerator.new(company_id, overseer_id)
    service.call
		puts "Job for Company - #{company_id} End"
	end
end
