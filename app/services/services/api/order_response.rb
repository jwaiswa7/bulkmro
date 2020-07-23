class Services::Api::OrderResponse < Services::Shared::BaseService
  
  def initialize(customer_order_object, api_request_object)
    @customer_order_object = customer_order_object
    @api_request_object = api_request_object
    @version    = CXML::Protocol.version
    @timestamp  = Time.now.utc
    @payload_id = "#{@timestamp.to_i}.#{Process.pid}.com"
  end

  def call
     
  end

  private

  attr_accessor :customer_order, :version, :timestamp, :payload_id, :api_request_object

end