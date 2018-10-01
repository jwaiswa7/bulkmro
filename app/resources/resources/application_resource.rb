class Resources::ApplicationResource
  include HTTParty
  #@@remote_exchange_log = ::Logger.new("#{Rails.root}/log/remote_exchange.log")
  #debug_output @@remote_exchange_log

  def self.new_session_id
    response = post(
        '/Login',
        :body => {:CompanyDB => DATABASE, :UserName => USERNAME, :Password => PASSWORD}.to_json,
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

  SAP = OpenStruct.new({
                           #attachment_directory: '/usr/sap/SAPBusinessOne/B1_SHF/Attachments',
                           attachment_directory: '/usr/sap/SAPBusinessOne/B1_SHF/Sprint',
                           attachment_api: '172.31.13.105/b1_shf/Attachments',
                           server: {host: '35.154.19.43', port: 22},
                           login: {user: 'b1service0', password: 'b1service0@123'},
                           draft_doc_object_code: 17, # 22 for Live SAP
                           draft_base_type: 23 # 17 for Live SAP #TODO
                       })


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
    elsif model_name == 'Attachment'
      'Attachments2'
    else
      model_name.pluralize
    end

  end

  # Subclass implements
  def self.identifier
    nil
  end

  def self.all
    get("/#{collection_name}").parsed_response['value'].map {|pr| OpenStruct.new(pr)}
  end

  def self.find(id)
    OpenStruct.new(get("/#{collection_name}(#{id})").parsed_response)
  end

  def self.create(record)
    #log and Validate Response
    response = post("/#{collection_name}", body: to_remote(record).to_json)

    get_validated_response(:post, record, response)
  end

  def self.get_validated_response(method, record, raw_response)

    request = log_request(method, record)

    validated_response = validate_response(raw_response)
    request.response_message = validated_response

    # Update Return value if data is valid and set Remote Exchange Status
    response = nil
    if validated_response.status
      request.status = :success

      response = OpenStruct.new(validated_response.value)
      response = response.send(self.identifier)
    else
      request.status = :failed
    end

    request.save
    response
  end

  def self.get_validated_response_for_query(method, query, raw_response)

    request = log_query_request(method,query)

    validated_response = validate_response(raw_response)
    request.response_message = validated_response

    # Update Return value if data is valid and set Remote Exchange Status
    response = nil
    if validated_response.status
      request.status = :success
      puts validated_response.value
      response = OpenStruct.new(OpenStruct.new(validated_response.value).value.first)
      puts(response)
      response = response.send(self.identifier)
    else
      request.status = :failed
    end

    request.save
    response
  end

  def self.log_request(method, record)
    RemoteExchangeLog.create({
                                 method: method,
                                 resource: collection_name,
                                 request_message: to_remote(record).to_json,
                                 url: [ENDPOINT, "/#{collection_name}"].join(""),
                                 status: :pending
                             })
  end

  def self.log_query_request(method,query)
    RemoteExchangeLog.create({
                                 method: method,
                                 resource: collection_name,
                                 request_message: "Search for #{query}",
                                 url: [ENDPOINT, "/#{collection_name}"].join(""),
                                 status: :pending
                             })
  end

  def self.update(id, record, options = {})
    response = patch("/#{collection_name}(#{id})", body: to_remote(record).to_json)
    get_validated_response(:patch, record, response)
    id
  end

  def self.validate_response(response)
    validate = OpenStruct.new
    validate.status = false
    validate.value = response.parsed_response

    if response['odata.metadata'] || (200...300).include?(response.code)
      validate.status = true
      validate.message = 'Success'
    elsif response['error']
      validate.message = 'SAP Error :' + response['error']['message']['value']
    else
      validate.message = 'SAP Error / Warning :' + response.to_s
    end

    validate
  end

  #TODO
  # Handle Error for Wrong data sent or Issue in updating
  #
  #
  #


end

