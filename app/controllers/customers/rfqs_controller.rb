class Customers::RfqsController < Customers::BaseController
	def index
    authorize :rfq
		
    service = Services::Customers::Finders::CustomerRfqs.new(params, current_customers_contact, current_company)
    service.call
    @indexed_rfqs = service.indexed_records
    @rfqs = service.records
  end
end
