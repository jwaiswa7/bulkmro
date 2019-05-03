class Resources::Industry < Resources::ApplicationResource
  def self.identifier
    :IndustryCode
  end

  def self.to_remote(record)
    {
        IndustryDescription: record.name,
        IndustryName: record.name
    }
  end
end
