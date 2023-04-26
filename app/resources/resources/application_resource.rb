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

  ATTACHMENT_SSH = '-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----'

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
