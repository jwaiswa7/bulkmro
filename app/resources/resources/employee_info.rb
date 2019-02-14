

class Resources::EmployeeInfo < Resources::ApplicationResource
  def self.collection_name
    'EmployeesInfo'
  end

  def self.identifier
    :EmployeeID
  end

  def self.to_remote(record)
    {
        FirstName: record.full_name,
        LastName: record.last_name,
        JobTitle: record.designation.present? ? record.designation.truncate(15) : '',
        Active: 'Y',
        Remarks: record.parent.try(:full_name),
        EmployeeBranchAssignment: [
            { BPLID: 0 },
            { BPLID: 1 },
            { BPLID: 2 },
            { BPLID: 3 },
            { BPLID: 4 },
            { BPLID: 5 },
            { BPLID: 6 },
            { BPLID: 7 },
            { BPLID: 8 },
        ],
    }
  end
end
