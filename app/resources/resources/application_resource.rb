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
          timeout: 60
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
    #raw_response.body.force_encoding('UTF-8')
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
    p "error-message-log = #{response[:error_message]}"
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
