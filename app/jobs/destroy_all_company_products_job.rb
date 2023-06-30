# frozen_string_literal: true

class DestroyAllCompanyProductsJob < ActiveJob::Base
  # This Job will destroy all the company products in the background
  
  # include Sidekiq::Worker
  queue_as :default

  # If record is no longer available, it is safe to ignore
  discard_on ActiveJob::DeserializationError

  discard_on ActiveRecord::RecordNotFound

  def perform(company_id)
    company = Company.find(company_id)
    company.customer_products.each do |customer_product|
      unless customer_product.customer_order_rows.exists?
        customer_product.destroy
      end
    end
  end
end
