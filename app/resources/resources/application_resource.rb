require "resolv-replace"

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
