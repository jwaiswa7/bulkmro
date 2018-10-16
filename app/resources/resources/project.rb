class Resources::Project < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.to_remote(record)
    record.reload
    if record.inquiry_number.blank?
      raise
    end

    {
      Code: record.inquiry_number,
      Name: record.subject
    }
  end
end