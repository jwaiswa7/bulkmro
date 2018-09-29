class Resources::Project < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.to_remote(record)
    {
      Code: record.id,
      Name: record.subject
    }
  end

  def self.find(id)
    OpenStruct.new(get("/#{collection_name}(#{id})").parsed_response)
  end
  def self.find_by_name(query)
    response = get("/#{collection_name}?$select=Code,Name,ValidFrom&$filter=startswith(Name, '#{query}') &$orderby=Code&$top=1")
    get_validated_response_for_query(:get, query, response)
  end
end