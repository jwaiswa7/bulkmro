class Resources::Manufacturer < Resources::ApplicationResource
  def self.identifier
    :Code
  end

  def self.to_remote(record)
    {
        "ManufacturerName": record.name
    }
  end
end
