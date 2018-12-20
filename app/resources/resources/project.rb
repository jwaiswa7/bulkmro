class Resources::Project < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.create(record)
    response = post("/#{collection_name}", body: to_remote(record).to_json)

    log_request(:post, record)
    validated_response = get_validated_response(response)
    log_response(validated_response)

    if validated_response[:error_message].present? && validated_response[:error_message] == 'This entry already exists in the following tables (ODBC -2035)'
      record.inquiry_number
    elsif validated_response['code'].present?
      record.inquiry_number
    else
      nil
    end
  end

  def self.to_remote(record)
    record.reload
    raise if record.inquiry_number.blank?

    {
        Code: record.inquiry_number,
        Name: ["#{record.inquiry_number} - ", record.subject[0..50]].join
    }
  end
end