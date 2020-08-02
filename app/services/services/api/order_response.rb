class Services::Api::OrderResponse < Services::Shared::BaseService
  
  def initialize(customer_order_object, api_request_object)
    @customer_order_object = customer_order_object
    @api_request_object = api_request_object
    @timestamp  = Time.now.utc
    @payload_id = api_request_object.payload['payloadID']
    @header = CXML::Header.new(api_request_object.payload['Header'])
    @buyer_cookie = api_request_object.payload['Request']['PunchOutSetupRequest']['BuyerCookie']
  end

  def call
    node = CXML.builder
    debugger
    node.cXML(build_attributes) do |doc|
      doc.header {|n| header.render(n, true) } if @header
      punchout_order_message(node)
    end
    debugger
    node
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
    debugger
    test = order_message.render(node)
    debugger
    test
  end

  attr_accessor :customer_order_object, :header, :timestamp, :payload_id, :api_request_object, :buyer_cookie

end