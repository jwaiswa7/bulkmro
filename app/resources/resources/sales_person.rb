class Resources::SalesPerson < Resources::ApplicationResource

  def self.identifier
    :SalesEmployeeCode
  end

  def self.to_remote(record, options = {})
    {
        SalesEmployeeName: record.full_name,
        Remarks: record.parent.try(:full_name),
        Active: "tYES"
    }
  end

  def self.update(id, record, options = {})
    OpenStruct.new(patch("/#{collection_name}(#{id})", body: to_remote(record).to_json).parsed_response)
    id
  end
end