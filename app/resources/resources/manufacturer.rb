class Resources::Manufacturer < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.to_remote(record)
    {
        "Code": -1,
        "ManufacturerName": "- No Manufacturer -"#product brand
    }
  end
end