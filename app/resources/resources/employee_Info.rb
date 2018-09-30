class Resources::EmployeeInfo < Resources::ApplicationResource

  def self.identifier
    :EmployeeID
  end

  def self.to_remote(record)

    #Default 8 branches in SAP
    branch_assignments = {"EmployeeBranchAssignment" => []}
    for i in 0..8
      branch_assignments["EmployeeBranchAssignment"].push({"BPLID" => i})
    end
    {
        FirstName: record.full_name,
        LastName: record.last_name,
        JobTitle: record.designation,
        Active:'tYes',
        Remarks: record.parent.try(:full_name),
        EmployeeBranchAssignment: branch_assignments["EmployeeBranchAssignment"]
    }
  end

end