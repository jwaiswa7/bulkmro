class Resources::BusinessPartnerGroup < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.to_remote(record)
    {
        Name: record.name[0..19],
        Type: "bbpgt_CustomerGroup"
    }
  end

  def self.create(record)
    response = OpenStruct.new(post("/#{collection_name}", body: to_remote(record).to_json).parsed_response)
    response.send(self.identifier)
  end

  def self.update(id, record)
    OpenStruct.new(patch("/#{collection_name}('#{id}')", body: to_remote(record).to_json).parsed_response)
  end
end