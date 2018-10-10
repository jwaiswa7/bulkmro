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
end