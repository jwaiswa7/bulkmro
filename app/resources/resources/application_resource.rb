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
