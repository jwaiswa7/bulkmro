class Services::Api::OrderResponse < Services::Shared::BaseService
  include HTTParty
  
  def initialize(customer_order_object, api_request_object)
    @customer_order_object = customer_order_object
    @api_request_object = api_request_object
    @timestamp  = Time.now.utc
    @payload_id = api_request_object.payload['payloadID']
    header = api_request_object.payload['Header']
    header["Sender"]["UserAgent"] = "BulkMRO"
    @cxml_header = CXML::Header.new(header)
    @buyer_cookie = api_request_object.payload['Request']['PunchOutSetupRequest']['BuyerCookie']
    @api_endpoint = api_request_object.payload["Request"]["PunchOutSetupRequest"]["BrowserFormPost"]["URL"]
    # @api_endpoint = 'http://localhost:3000/api/v1/punchouts/route'
    # @api_endpoint = 'https://4cc1bfe26cca.ngrok.io/api/v1/punchouts/route'
    @cart_response_object = ApiCartResponse.create(api_request_id: api_request_object.id, buyer_cookie: buyer_cookie, api_endpoint: api_endpoint)
  end

  def call
    node = CXML.builder
    node.cXML(build_attributes) do |doc|
      doc.header {|n| cxml_header.render(n, true) } if cxml_header
      punchout_order_message(node)
    end
    
    send_response(params: node.to_xml)

    cart_response_object.update_attributes(payload: node.to_xml)
  end

  private

  def build_attributes
    attrs = {'payloadID' => api_request_object.payload['payloadID'], 'timestamp' => timestamp.iso8601}
    attrs
  end

  def punchout_order_message(node)
    main_array = []
    item_id_hash, item_detail_hash = {}
    header_data = {'BuyerCookie' => buyer_cookie, 
      'PunchOutOrderMessageHeader' => {
        'Total' => {
          'Money' => {'currency' => 'INR', 'content' => customer_order_object.calculated_total.to_i}
        }  
      }
    }

    customer_order_object.items.each do |item|
      item_hash = { 'quantity' => item.quantity.to_i,
        'ItemID' => {'SupplierPartID' => item.customer_product.sku, 'SupplierPartAuxillaryID' => item.customer_product.sku }, 
        'ItemDetail' => { 'Description' => item.customer_product.name, 
          'UnitOfMeasure' => item.customer_product.measurement_unit.present? ? item.customer_product.measurement_unit.name : 'EA',
          'ClassificationUnspsc' => '',
          'UnitPrice' => { 'Money' => {'currency' => 'INR', 'content' => item.customer_product.customer_price.to_i } }
        }
      }
      main_array << item_hash
    end

    order_message = CXML::PunchOutOrderMessage.new(header_data)
    main_array.each do |item|
      order_message.add_item(item)
    end
    order_message.render(node)
  end

  def send_response(params: {})
    response = HTTParty.post(api_endpoint, body: params, headers: {
      'Content-Type': 'application/xhtml+xml',
      'Accept': 'text/html'
     })
    validated_response = get_validated_response(response)
    if validated_response.present?
      cart_response_object.update_attributes(response: validated_response)
    else
      cart_response_object.update_attributes(response: 'No response received')
    end
  end

  def get_validated_response(raw_response)
    if raw_response['success'] == true
      OpenStruct.new(raw_response.parsed_response.deep_symbolize_keys)
    elsif raw_response['error']
      { raw_response: raw_response, error_message: raw_response['error']['message'] }
    else
      { raw_response: raw_response, error_message: raw_response.to_s }
    end
  end

  attr_accessor :customer_order_object, :cxml_header, :timestamp, :payload_id, :api_request_object, :buyer_cookie, :api_endpoint, :cart_response_object

end