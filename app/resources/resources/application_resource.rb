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

  ATTACHMENT_SSH = '-----BEGIN OPENSSH PRIVATE KEY-----
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
ytGSzNhgc5tk1QAAAAhzYXBhZG1pbgE=
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
