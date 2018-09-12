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
end