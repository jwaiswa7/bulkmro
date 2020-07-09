class Services::Api::Cxml < Services::Shared::BaseService
  
  def initialize(params = {})
    @params = params
    @version    = CXML::Protocol.version
    @timestamp  = Time.now.utc
    @payload_id = "#{@timestamp.to_i}.#{Process.pid}.com"
  end

  def parser
    if params.body.present?
      parsed_body = CXML.parse(params.body)
      contact_email = parsed_body["Request"]["PunchOutSetupRequest"]["Extrinsic"].select{|hash| hash["name"] == "UserEmail"}.first["content"]
      landing_url = "http://localhost:3000/customers/dashboard/route?email=#{contact_email}"
      
      response_data = { 'Status' => { 'code' => "200", 'text' => "OK" },
                        'PunchOutSetupResponse' => { 'StartPage' => { 'URL' => landing_url } } }
      response = CXML::Response.new(response_data)

      if contact_email.present?
        contact = Contact.find_by(email: contact_email)
        if contact.present?
          node = CXML.builder
          node.cXML('payloadID' => payload_id, 'timestamp' => timestamp.iso8601) do |doc|
            response.render(node)
          end
          node
        end
      end
    end
  end

  private

  attr_accessor :params, :version, :timestamp, :payload_id

end