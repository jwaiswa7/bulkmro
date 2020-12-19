class Services::Api::Cxml < Services::Shared::BaseService
  def initialize(params = {}, api_request_object)
    @params = params
    @api_request_object = api_request_object
    @version    = CXML::Protocol.version
    @timestamp  = Time.now.utc
    @payload_id = "#{@timestamp.to_i}.#{Process.pid}.com"
  end

  def parser
    if params.body.present?
      parsed_body = CXML.parse(params.body)
      contact_email = parsed_body["Request"]["PunchOutSetupRequest"]["Extrinsic"].select{|hash| hash["name"] == "UserEmail"}.first["content"].downcase
      header = parsed_body["Header"]

      landing_url = "https://sprint.bulkmro.com/customers/dashboard/route?email=#{contact_email}&amp;request_id=#{api_request_object.hashid}"
      # landing_url = "http://localhost:3000/customers/dashboard/route?email=#{contact_email}&amp;request_id=#{api_request_object.hashid}"

      response_data = { 'Status' => { 'code' => "200", 'text' => "OK" },
                        'PunchOutSetupResponse' => { 'StartPage' => { 'URL' => landing_url } } }
      response = CXML::Response.new(response_data)
      
      api_request_object.update_attributes(payload: parsed_body, contact_email: contact_email, request_header: header.to_json)

      contact = Contact.find_by(email: contact_email)

      if contact.present?
        node = CXML.builder
        node.cXML('payloadID' => payload_id, 'timestamp' => timestamp.iso8601) do |doc|
          response.render(node)
        end
        api_request_object.update_attributes(response: node, updated_at: Time.now.iso8601)
        node
      else
        api_request_object.update_attributes(error_message: "Contact is not present in the system".to_json, updated_at: Time.now.iso8601)
      end
    else
      api_request_object.update_attributes(error_message: "Request body is empty".to_json, updated_at: Time.now.iso8601)
    end
  end

  private

  attr_accessor :params, :version, :timestamp, :payload_id, :api_request_object
end
