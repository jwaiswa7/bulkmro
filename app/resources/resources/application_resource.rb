class Resources::ApplicationResource
  include HTTParty

  def self.new_session_id
    response = post(
            '/Login',
            :body => { :CompanyDB => DATABASE, :UserName => USERNAME, :Password => PASSWORD}.to_json,
            :verify => false,
            :debug_output => $stdout,
            :timeout => 30
        )

    response['SessionId']
  end

  def self.get_sap_cookie
    Rails.cache.fetch('sap_cookie', expires_in: 25.minutes) do
      "B1SESSION=#{new_session_id}; path=#{ENDPOINT.path}; domain=#{[ENDPOINT.scheme, '://', ENDPOINT.host].join}; HttpOnly; Expires=Tue, 19 Jan 2018 03:20:07 GMT"
    end
  end

  ENDPOINT = URI.parse('https://35.154.19.43:50000/b1s/v1')
  DATABASE = 'BMRO_JULY05'
  USERNAME = 'manager'
  PASSWORD = 'bm@123'
  base_uri ENDPOINT.to_s
  debug_output($stdout)
  default_options.merge!(verify: false, timeout: 30)
  headers({
              :'Content-Type' => 'application/json',
              :'Access-Control-Allow-Origin' => '*',
              :'Cookie' => get_sap_cookie
          })


  # Project
  def self.model_name
    self.name.split('::').last.to_s
  end

  # Projects
  def self.collection_name
    if model_name == 'SalesPerson'
      'SalesPersons'
    else
      model_name.pluralize
    end

  end

  # Subclass implements
  def self.identifier
    nil
  end

  def self.all
    get("/#{collection_name}").parsed_response['value'].map { |pr| OpenStruct.new(pr) }
  end

  def self.find(id)
    OpenStruct.new(get("/#{collection_name}('#{id}')").parsed_response)
  end

  def self.create(record)
    response = OpenStruct.new(post("/#{collection_name}", body: to_remote(record).to_json).parsed_response)
    response.send(self.identifier)
  end

  def self.update(id, record, options = {})
    OpenStruct.new(patch("/#{collection_name}(#{id})", body: to_remote(record).to_json).parsed_response)
    id
  end

  #TODO
  # Handle Error for Wrong data sent or Issue in updating
  #
  #
  def format_date
  end
end