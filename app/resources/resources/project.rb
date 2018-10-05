class Resources::Project < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.to_remote(record)
    {
      Code: record.inquiry_number,
      Name: record.subject
    }
  end

  def self.find(id)
    OpenStruct.new(get("/#{collection_name}(#{id})").parsed_response)
  end

  def self.find_by_name(name)
    response = get("/#{collection_name}?$select=Code,Name,ValidFrom&$filter=startswith(Name, '#{name}') &$orderby=Code&$top=1")
    validated_response = get_validated_response(response)
    log_request(:get, name, validated_response, is_query: true)

    if validated_response['value'].present? && validated_response['value']['value'].present?
      validated_response['value']['value'][0][self.identifier]
    end
  end
end