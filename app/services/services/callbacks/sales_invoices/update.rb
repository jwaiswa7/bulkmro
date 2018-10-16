class Services::Callbacks::SalesInvoices::Update < Services::Callbacks::Shared::BaseCallback

  def initialize(params)
    @params = params
  end

  def call
    sales_invoice = SalesInvoice.find_by_invoice_number!(params['increment_id'])
    sales_invoice.update_attributes(:status => params['state'])

    # todo comments
  end

  attr_accessor :params
end

# {
#     "increment_id":"20610329",
#     "state":"206",
#     "comment":"BasedOnSalesQuotations1731.BasedOnSalesOrders10610269.BasedOnDeliveries30610471."
# }