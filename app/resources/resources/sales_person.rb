

class Resources::SalesPerson < Resources::ApplicationResource
  def self.collection_name
    'SalesPersons'
  end

  def self.identifier
    :SalesEmployeeCode
  end

  def self.to_remote(record)
    {
        SalesEmployeeName: record.full_name,
        Remarks: record.parent.try(:full_name),
        Active: 'tYES'
    }
  end
end
