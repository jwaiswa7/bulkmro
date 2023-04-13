class Resources::ApplicationResource
  include HTTParty
  # @@remote_exchange_log = ::Logger.new("#{Rails.root}/log/remote_exchange.log")
  # debug_output @@remote_exchange_log

  def self.new_session_id
     response = HTTParty.post(
       'https://34.93.93.47:50000/b1s/v1/Login',
         body: {CompanyDB: Settings.sap.DATABASE, UserName: Settings.sap.USERNAME, Password: Settings.sap.PASSWORD}.to_json,
         verify: false,
         debug_output: $stdout,
         timeout: 30
     )
     response['SessionId']
  end

  def self.get_sap_cookie
    Rails.cache.fetch('sap_cookie', expires_in: 20.minutes) do
      "B1SESSION=#{new_session_id}; path=#{ENDPOINT.path}; domain=#{[ENDPOINT.scheme, '://', ENDPOINT.host].join}; HttpOnly; Expires=#{(DateTime.now - 1.day).strftime('%a, %d %b %Y %T') }"
    end
  end

  ENDPOINT = URI.parse(Settings.sap.ENDPOINT)
  ATTACHMENT_ENDPOINT = URI.parse(Settings.sap.ATTACHMENT_ENDPOINT)

  ATTACHMENT_SSH = '-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAr6ALVxKsoMWYCXBPAYdE+aqCvoAe8CKNStksYfsWiQjQYBHg
Z4WIcoY3RHqGFCfIIHsQQYDxWlRp7OxYdnDxpUx+Y59cZ2RZAuNkM5LQehPuH7Js
AYmPqYRErxqKznFx/ECxE5W/0FhYd4lT9Zm0vJGHbfd7Lz5CdP4/inP2cRu4ghlC
XkxmnWvfYcPx9eXk3pycLvtcIdGv/DEWalTSVOOyj1RBYjg69FMMBq4uqLVQeQoD
6j83GSn4kLYAomfbYXaAMj65HvDOb3jM5ufPj6pqyiW0pB7rlVCVxLayYu7ZPqpQ
WP09o2kSsW6Biyq6zUQdopWcu0HP+frgAk+uLQIDAQABAoIBAF38SBVQ6REgrTxf
3efze/YgSdeouOXJl9N2ZUoKFQVAskK3TmAYFe0z5l+/MgGXSIIZWZm0Z3Tvt8AS
u0SnLKpJRVoK7mhmSzxAdF8lMmwiPky4LxSjiT4uipMqoR3ZmCZmeF0CxqO4o59U
3pmQqChBuTggOMwPhYEWjuqJJFlimLQGlQNCfCM1epE94nUTtnG+f07Fajvuj0i3
id8DNlS/XrX1GWoq8SvRBekQH6eReVSv87qm5my3Wkhy9cDn5OXxT7jmkBF+jQ/Z
0M0e3lLINDVpqk64dqDhDGYNy+vEiJCR7L96D6CaCUa84cPBueHfxbaRQU9MfTi6
8kkvYAECgYEA5W4xCryb9NIOs2tY4If7Xy5jsmYxpE7cq1MupujGbPp/KOv2Cb3D
IWEio522tvx2DngfH4Kmpmiw0dFkzZn0P9cWVzTsi1iHRTrc2hVq5PTTFV14QBnJ
4KAroxrC6qmkd9Y2Sn4LNlChmuKa9vFywGd8tNGTkZ3ZYTtienDz0PkCgYEAw/a3
Gal1lmyjBwIm9BgIGjQKTpez0BsvVJtpim+1eyJo1WUXkKP1XhSTFNUvdlT/fB6D
lwNuR6uVmLvzUI1fthE4hwvfqSlXj6P5m6TCrBxttL2+giS0xSqxspyuRtYiSl0M
VZyH3+NK5ki1WRPakI+irrnzJ1+kmp5rPG2cB9UCgYB5TxYnMyrS++5B99R6g+vp
m8GjJl3BHuGWxNi58AJaxOhPXtQsumVeVNnX4SAnCL3zUJhENPSgsGItzqWaAHkg
+D0bxyP7WcfMVx9HQGPQw5KIjW9zlS8k0gvApfnB0gjgRCdYo+SRx3hrSL3fLDMc
gJtzkAySxf+WZavgSbDhIQKBgAzYd1gvS434wRcMhRErIhzVnHdaamcR4SBir6Br
gjH4J3cVkV3h4YuxPZL4BoxzNewk8+tKRkhcbwn8CA8XtVZx+oqftKGaHCtGTG5v
dnNhya83YO2XCmKCUfOrYaEzGDxXrR9Pi3iZpadCzOBx9LnVMIzTk6TZGCkqiU0E
wl2hAoGATFrC5tx5kc7LoSVUOXh5itki9UKpVrrKHXKNmiDDZIzpfLvJdWT/Z+3u
mTp73liK9Awiw2hvZzi2KlLblWnutk8gU4LyUVsPf8uTr2vbevLr7AFantaG1oEZ
rk2lN8RYmRBSFFAVqd5ZboaYKbGz0S997cK7QG8vpQRawmzcfNo=
-----END RSA PRIVATE KEY-----'

  SAP = OpenStruct.new(
    attachment_directory: Settings.sap.ATTACHMENT_DIRECTORY,
    attachment_api: Settings.sap.ATTACHMENT_API,
    server: {host: ATTACHMENT_ENDPOINT.host, port: ATTACHMENT_ENDPOINT.port},
    login: {user: Settings.sap.ATTACHMENT_USERNAME, password: Settings.sap.ATTACHMENT_PASSWORD},
    draft_doc_object_code: 17,
    draft_base_type: 23,
    attachment_username: Settings.sap.ATTACHMENT_USERNAME,
    ssh_key: ATTACHMENT_SSH
  )

  def self.set_headers
    base_uri ENDPOINT.to_s
    debug_output($stdout)
    default_options.merge!(verify: false, timeout: 30)
    headers(
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Cookie': get_sap_cookie,
      'B1S-ReplaceCollectionsOnPatch': 'true'
    )
  end

  set_headers

  def self.model_name
    self.name.split('::').last.to_s
  end

  def self.collection_name
    model_name.pluralize
  end

  def self.identifier
    nil
  end

  def self.to_remote(record, dependent_record = nil)
    if !dependent_record.nil?
      [record, dependent_record]
    else
      record
    end
  end

  def self.to_remote_json(record)
    self.to_remote(record, dependent_record).to_json
  end

  def self.all
    get("/#{collection_name}").parsed_response['value'].map { |pr| OpenStruct.new(pr) }
  end

  def self.find(id, quotes: false)
    response = perform_remote_sync_action('get', "/#{collection_name}(#{quotes ? ["'", id, "'"].join : id})", '')
    OpenStruct.new(response.parsed_response) if response.present? && response.parsed_response.present? && (response.parsed_response.is_a? Hash)
  end

  def self.custom_find(id, by = nil)
    url = "/#{collection_name}?$filter=#{by ? by : identifier} eq '#{id}'&$top=1"
    response = perform_remote_sync_action('get', url)

    log_request(:get, id, is_find: true)
    validated_response = get_validated_response(response)
    log_response(validated_response, 'get', url, '')

    if validated_response['value'].present?
      remote_record = validated_response['value'][0]
      yield remote_record if block_given?
      remote_record[self.identifier.to_s]
    end
  end

  def self.custom_find_resync(id, by = nil, resync_request = nil)
    url = "/#{collection_name}?$filter=#{by ? by : identifier} eq '#{id}'&$top=1"
    response = perform_remote_sync_action('get', url)
    validated_response = get_validated_response(response)

    if validated_response['value'].present?
      remote_record = validated_response['value'][0]
      yield remote_record if block_given?
      resync_request.update_attributes(status: 10, resync_response: validated_response, resync_url: url) if resync_request.present?
      remote_record[self.identifier.to_s]
    else
      resync_request.update_attributes(status: 20, resync_response: validated_response, resync_url: url) if resync_request.present?
      false
    end
  end

  def self.create(record, dependent_record = nil)
    url = "/#{collection_name}"
    if dependent_record.nil?
      body = to_remote(record).to_json
    else
      body = to_remote(record, dependent_record).to_json
    end
    response = perform_remote_sync_action('post', url, body)
    log_request(:post, record, dependent_record)
    validated_response = get_validated_response(response)
    log_response(validated_response, 'post', url, body)

    yield validated_response if block_given?
    validated_response[self.identifier]
  end

  def self.update(id, record, quotes: false)
    url = "/#{collection_name}(#{quotes ? ["'", id, "'"].join : id})"
    body = to_remote(record).to_json
    response = perform_remote_sync_action('patch', url, body)
    log_request(:patch, record)
    validated_response = get_validated_response(response)

    log_response(validated_response, 'patch', url, body)

    yield validated_response if block_given?
    id
  end

  def self.temp_update(id, record, quotes: false)
    url = "/#{collection_name}(#{quotes ? ["'", id, "'"].join : id})"
    body = to_remote(record).to_json
    response = perform_remote_sync_action('patch', url, body)
    log_request(:patch, record)
    validated_response = get_validated_response(response)

    log_response(validated_response, 'patch', url, body)

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

  def self.cancel_document(record)
    record_remote_uid = record.remote_uid
    remote_json = {}
    if record_remote_uid.present?
      url = "/#{collection_name}(#{record.remote_uid})/Cancel"
      response = perform_remote_sync_action('post', url)
      log_request(:post, record, stored_body: false)
      validated_response = get_validated_response(response)
      remote_request = log_response(validated_response, 'patch', url)
      if remote_request.status == 'success'
        remote_json['status'] = 'success'
        remote_json['message'] = 'SO Cancel Successfully'
      elsif remote_request.status == 'failed'
        remote_json['status'] = 'failed'
        remote_json['message'] = remote_request.response['raw_response']['error']['message']['value']
      end
      remote_json
    end
  end

  def self.log_request(method, record, dependent_record = nil, is_find: false, stored_body: true)
    @resource = if dependent_record.nil?
      if stored_body
        if record.is_a?(String)
          record
        else
          to_remote(record)
        end
      else
        ''
      end
    else
      to_remote(record, dependent_record)
    end
    @remote_request = RemoteRequest.create!(
      subject: record.is_a?(String) ? nil : record,
      method: method,
      is_find: is_find,
      resource: collection_name,
      request: @resource,
      url: [ENDPOINT, "/#{collection_name}"].join(''),
      status: :pending
    )

    @remote_request
  end

  def self.log_response(response, method = 'get', url = '', body = '')
    status = :success
    if response[:error_message].present? && (response[:error_message].downcase.include? 'invalid session')
      Rails.cache.delete('sap_cookie')
      status = :failed
      set_headers
    elsif response[:error_message].present?
      status = :failed
      if !method.equal? 'get'
        @resync_remote_request = ResyncRemoteRequest.create!(
          subject: @remote_request.subject,
          method: method,
          resource: @remote_request.resource,
          request: @remote_request.request,
          url: @remote_request.url,
          status: @remote_request.status
        )
        @resync_remote_request.update_attributes(response: response, status: status, hits: 0)
        @resync_remote_request

        resync_service = Services::Resources::Shared::ResyncFailedRequests.new(@resync_remote_request)
        resync_service.call
      end
    end

    @remote_request.update_attributes(response: response, status: status)
    @remote_request
  end

  def self.perform_remote_sync_action(action, url, body = '')
    begin
      if body.present?
        send(action, url, body: body)
      else
        send(action, url)
      end
    rescue Exception => e
      Rails.cache.delete('sap_cookie')
      send(action, url, body: body)
    end
  end
end
