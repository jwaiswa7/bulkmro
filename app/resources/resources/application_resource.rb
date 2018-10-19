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

  if Rails.env.development?
    ENDPOINT = URI.parse('https://35.154.19.43:50000/b1s/v1')
    DATABASE = 'SPRINT_TEST'
    USERNAME = 'manager'
    PASSWORD = 'vm1234'

    ATTACHMENT_ENDPOINT = URI.parse('https://172.31.13.105:22')
    ATTACHMENT_USERNAME = 'pradeep'
    ATTACHMENT_PASSWORD = ''
    ATTACHMENT_SSH = '-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA9bBug/z3ZxZnfS4sBNolGjq3+JFWb8odFtq55m7w+zsAe6uC
fPkIJaDdJfqwr6sk3991heT93CbqLf9ZWS6sDLJpQ2d5a/rEO8n2H10WPb1DmT9P
YQC3zotMktGq7ENYL7QBDgXK1VOsV2JRnvSr6i8i9OQjOATp/1YxLdE0wh6/Qym5
S+rU825YZED2GpeHJIVUvFuRjXFPASQQsV7BwM5Msp+FRWFmOlHilDDFpPjSQSOK
lnkkaFBXPMox56OTb/+4Ihkmd+Oawl0ofuxWmlWUrzxevlL2Xa7EJki1WidrcXYI
nqEW/afe/YMWZ/wDWO77QGfwUang+erBJBdfjwIDAQABAoIBAFzVRHz0yZqXGZVw
K8vNjXViuH7gk7N7wBARp2qNgtq6yYzxGkYUZuKo7Mbb+YT2+uDoc2SbSNy1i4jD
0kPjYbkOdL22TGfjgeBBiJEDQFMlv3QZOuohNlKByfYz6QyKybiEoF1nDOQcUKNY
EBUqyAadtuyngzM4kB4duEliojeyXvYlUaTYOTJqlEhKoRPqYxgy/44+qw0Bt4ta
ZeabeaNvRPMD9qnsBRz29Yfv0BIaXOYTZyWlg09pbmFuBEAHRwg6NQHgOuKHX9Hl
v/x2gAdo8NrTPkLHiqc50hDjctHVPjiukxRea/J4OrwCgIkwER+Amozmx/df14BR
KhdfkqkCgYEA+tRvT/kq2Fo0y0LrxPKT4obj1fcatQCFTn0+S4m68/iT1vAowX4w
4XW6CEzZgxIl0/ngTjibl3+h4kFEUfp0OQkN+4EV0xzTTtBOybd1O6iaWB5zwu8c
aSyJYlxSwbn8BVYl6z94NpG6lMoJo+QoGwH04tU+Ks61HbGe16xx040CgYEA+sDe
/Uy8Ds63SQOx07njlbPIwu/SrQ+grxemHc2c1V8E+j+ghfU/pIwQcLqN6sDIUGjG
fBw7oxWve4nKW2HqkDy7U1M/gW9IOL67fd0D1NfbDeGtcIDXvLqAj2c3lzYZ2CgF
PTFTfJQJWvzN+b0/yAxcK+aIkoiCdPB6iDueCosCgYEApH1fqhB62nr9mDaAqx1x
geJ30z9DUmPPCBP2IE9oPMpNGW1RLOL2Z0RvBTZwhhYGnKaHRIS29HkMznWCukgG
o8ieVMroZxPGNy9AG+SlisQcw6DkxXdNKGO+jLSCyOyQq2c9YrKywQZ8V0rPW50p
99wmngK9zBDWkWyEAGfkFZkCgYAtAroEVeXb8pdL7/HXw6JqmN8MvufeUNPTGjej
WekxE+Fc2lcCNMe7zbiVw6b94KUUafpXBOpfl+DsGAvO44Cra3tktajMnyEjrnkR
Wr75UdXsY/oyG66eHgw9sZV0+y0gc+6c0WHfFuOnBYIjtijgy/cvmi4hv4dLXm9g
TPNNiQKBgQCvM1FiwATvx88AltNTeaCD3UzUr9ND2UnARYW+Fy4tJBYb0hUBtqeq
tq7iFj/oZ0WuMVBpik7S47FVc9SeuWTUcbRwC87lF5aobMyUNIaxc06+4zR9Hl5X
ulmwwTdSSRVmjSfz4OxPuSNQdXmYhHDkXMKfewl4mkEJSp92a1HHXw==
-----END RSA PRIVATE KEY-----'

    SAP = OpenStruct.new({
                             attachment_directory: '/usr/sap/SAPBusinessOne/B1_SHF/Sprint',
                             attachment_api: '172.31.13.105/b1_shf/Sprint',
                             server: {host: ATTACHMENT_ENDPOINT.host, port: ATTACHMENT_ENDPOINT.port},
                             login: {user: ATTACHMENT_USERNAME, password: ATTACHMENT_PASSWORD},
                             draft_doc_object_code: 17,
                             draft_base_type: 23,
                             attachment_username: ATTACHMENT_USERNAME,
                             ssh_key: ATTACHMENT_SSH
                         })
  end

  if Rails.env.production?
    ENDPOINT = URI.parse('https://35.200.144.191:50000/b1s/v1')
    DATABASE = 'BULKMRO_PRODUCTION'
    USERNAME = 'manager'
    PASSWORD = 'vm1234'

    ATTACHMENT_ENDPOINT = URI.parse('https://35.200.144.191:22')
    ATTACHMENT_USERNAME = 'pradeep'
    ATTACHMENT_PASSWORD = ''
    ATTACHMENT_SSH = '-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA9bBug/z3ZxZnfS4sBNolGjq3+JFWb8odFtq55m7w+zsAe6uC
fPkIJaDdJfqwr6sk3991heT93CbqLf9ZWS6sDLJpQ2d5a/rEO8n2H10WPb1DmT9P
YQC3zotMktGq7ENYL7QBDgXK1VOsV2JRnvSr6i8i9OQjOATp/1YxLdE0wh6/Qym5
S+rU825YZED2GpeHJIVUvFuRjXFPASQQsV7BwM5Msp+FRWFmOlHilDDFpPjSQSOK
lnkkaFBXPMox56OTb/+4Ihkmd+Oawl0ofuxWmlWUrzxevlL2Xa7EJki1WidrcXYI
nqEW/afe/YMWZ/wDWO77QGfwUang+erBJBdfjwIDAQABAoIBAFzVRHz0yZqXGZVw
K8vNjXViuH7gk7N7wBARp2qNgtq6yYzxGkYUZuKo7Mbb+YT2+uDoc2SbSNy1i4jD
0kPjYbkOdL22TGfjgeBBiJEDQFMlv3QZOuohNlKByfYz6QyKybiEoF1nDOQcUKNY
EBUqyAadtuyngzM4kB4duEliojeyXvYlUaTYOTJqlEhKoRPqYxgy/44+qw0Bt4ta
ZeabeaNvRPMD9qnsBRz29Yfv0BIaXOYTZyWlg09pbmFuBEAHRwg6NQHgOuKHX9Hl
v/x2gAdo8NrTPkLHiqc50hDjctHVPjiukxRea/J4OrwCgIkwER+Amozmx/df14BR
KhdfkqkCgYEA+tRvT/kq2Fo0y0LrxPKT4obj1fcatQCFTn0+S4m68/iT1vAowX4w
4XW6CEzZgxIl0/ngTjibl3+h4kFEUfp0OQkN+4EV0xzTTtBOybd1O6iaWB5zwu8c
aSyJYlxSwbn8BVYl6z94NpG6lMoJo+QoGwH04tU+Ks61HbGe16xx040CgYEA+sDe
/Uy8Ds63SQOx07njlbPIwu/SrQ+grxemHc2c1V8E+j+ghfU/pIwQcLqN6sDIUGjG
fBw7oxWve4nKW2HqkDy7U1M/gW9IOL67fd0D1NfbDeGtcIDXvLqAj2c3lzYZ2CgF
PTFTfJQJWvzN+b0/yAxcK+aIkoiCdPB6iDueCosCgYEApH1fqhB62nr9mDaAqx1x
geJ30z9DUmPPCBP2IE9oPMpNGW1RLOL2Z0RvBTZwhhYGnKaHRIS29HkMznWCukgG
o8ieVMroZxPGNy9AG+SlisQcw6DkxXdNKGO+jLSCyOyQq2c9YrKywQZ8V0rPW50p
99wmngK9zBDWkWyEAGfkFZkCgYAtAroEVeXb8pdL7/HXw6JqmN8MvufeUNPTGjej
WekxE+Fc2lcCNMe7zbiVw6b94KUUafpXBOpfl+DsGAvO44Cra3tktajMnyEjrnkR
Wr75UdXsY/oyG66eHgw9sZV0+y0gc+6c0WHfFuOnBYIjtijgy/cvmi4hv4dLXm9g
TPNNiQKBgQCvM1FiwATvx88AltNTeaCD3UzUr9ND2UnARYW+Fy4tJBYb0hUBtqeq
tq7iFj/oZ0WuMVBpik7S47FVc9SeuWTUcbRwC87lF5aobMyUNIaxc06+4zR9Hl5X
ulmwwTdSSRVmjSfz4OxPuSNQdXmYhHDkXMKfewl4mkEJSp92a1HHXw==
-----END RSA PRIVATE KEY-----'

    SAP = OpenStruct.new({
                             attachment_directory: '/usr/sap/SAPBusinessOne/B1_SHF/Attachments',
                             attachment_api: '35.200.144.191/b1_shf/Attachments',
                             server: {host: ATTACHMENT_ENDPOINT.host, port: ATTACHMENT_ENDPOINT.port},
                             login: {user: ATTACHMENT_USERNAME, password: ATTACHMENT_PASSWORD},
                             draft_doc_object_code: 17,
                             draft_base_type: 23,
                             attachment_username: ATTACHMENT_USERNAME,
                             ssh_key: ATTACHMENT_SSH
                         })

  end


  base_uri ENDPOINT.to_s
  debug_output($stdout)
  default_options.merge!(verify: false, timeout: 30)
  headers({
              :'Content-Type' => 'application/json',
              :'Access-Control-Allow-Origin' => '*',
              :'Cookie' => get_sap_cookie
          })


  def self.model_name
    self.name.split('::').last.to_s
  end

  def self.collection_name
    model_name.pluralize
  end

  def self.identifier
    nil
  end

  def self.to_remote(record)
    record
  end

  def self.to_remote_json(record)
    self.to_remote(record).to_json
  end

  def self.all
    get("/#{collection_name}").parsed_response['value'].map {|pr| OpenStruct.new(pr)}
  end

  def self.find(id, quotes: false)
    OpenStruct.new(get("/#{collection_name}(#{quotes ? ["'", id, "'"].join : id})").parsed_response)
  end

  def self.custom_find(id, by = nil)
    response = get("/#{collection_name}?$filter=#{by ? by : identifier} eq '#{id}'&$top=1")

    log_request(:post, id, is_find: true)
    validated_response = get_validated_response(response)
    log_response(validated_response)

    if validated_response['value'].present?
      remote_record = validated_response['value'][0]
      yield remote_record if block_given?
      remote_record[self.identifier.to_s]
    end
  end

  def self.create(record)
    response = post("/#{collection_name}", body: to_remote(record).to_json)

    log_request(:post, record)
    validated_response = get_validated_response(response)
    log_response(validated_response)

    yield validated_response if block_given?
    validated_response[self.identifier]
  end

  def self.update(id, record, quotes: false)
    response = patch("/#{collection_name}(#{quotes ? ["'", id, "'"].join : id})", body: to_remote(record).to_json)

    log_request(:patch, record)
    validated_response = get_validated_response(response)
    log_response(validated_response)

    yield validated_response if block_given?
    id
  end

  def self.get_validated_response(raw_response)
    if raw_response['odata.metadata'] || (200...300).include?(raw_response.code)
      OpenStruct.new(raw_response.parsed_response)
    elsif raw_response['error']
      # raise(raw_response.to_s) if Rails.env.development?
      {raw_response: raw_response, error_message: raw_response['error']['message']['value']}
    else
      # raise(raw_response.to_s) if Rails.env.development?
      {raw_response: raw_response, error_message: raw_response.to_s}
    end
  end

  def self.log_request(method, record, is_find: false)
    @remote_request = RemoteRequest.create!({
                                                subject: record.is_a?(String) ? nil : record,
                                                method: method,
                                                is_find: is_find,
                                                resource: collection_name,
                                                request: record.is_a?(String) ? record : to_remote(record),
                                                url: [ENDPOINT, "/#{collection_name}"].join(""),
                                                status: :pending
                                            })

    @remote_request
  end

  def self.log_response(response)
    @remote_request.update_attributes(:response => response, status: :success)
    @remote_request
  end
end