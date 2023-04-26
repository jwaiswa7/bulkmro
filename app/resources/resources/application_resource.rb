class Resources::ApplicationResource
  include HTTParty
  # @@remote_exchange_log = ::Logger.new("#{Rails.root}/log/remote_exchange.log")
  # debug_output @@remote_exchange_log

  def self.new_session_id
     response = HTTParty.post(
       'https://35.244.5.222:50000/b1s/v1/Login',
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
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
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
