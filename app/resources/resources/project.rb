class Resources::Project < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.to_remote(record)
    record.reload
    raise if record.inquiry_number.blank?

    {
      Code: record.inquiry_number,
      Name: record.subject
    }
  end
end