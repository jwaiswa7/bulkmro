require "resolv-replace"

class Resources::ApplicationResource
  include HTTParty
  # @@remote_exchange_log = ::Logger.new("#{Rails.root}/log/remote_exchange.log")
  # debug_output @@remote_exchange_log

  def self.new_session_id
     begin
      response = HTTParty.post(
        'https://35.244.5.222:50000/b1s/v1/Login',
          body: {CompanyDB: Settings.sap.DATABASE, UserName: Settings.sap.USERNAME, Password: Settings.sap.PASSWORD}.to_json,
          verify: false,
          debug_output: $stdout,
          timeout: 30
      )
      response['SessionId']
     rescue => exception
      Rails.logger.error exception   
     end
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
