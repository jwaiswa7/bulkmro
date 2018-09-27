class Resources::SalesPerson < Resources::ApplicationResource

  def self.identifier
    :SalesEmployeeCode
  end

  def self.to_remote(record)
    {
        FirstName: record.full_name,
        LastName: record.last_name,
        JobTitle: record.designation,
        Active:'tYes',
        Remarks: record.parent.try(:full_name),
        Active: "tYES"
    }
  end

end