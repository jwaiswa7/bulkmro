class Resources::SalesOpportunity < Resources::ApplicationResource

  def self.identifier
    :SequentialNo
  end

  def self.to_remote(record)
    {
        CardCode: record.company.remote_uid, #
        U_SalesMgr: record.sales_manager.try(:full_name),
        StartDate: record.created_at.strftime('%F'),
        MaxSystemTotal: record.potential_amount,
        ProjectCode: record.project_uid,
        Status: "sos_Open",
        PredictedClosingDate: (record.created_at + 2.months).strftime('%F'),
        OpportunityName: record.subject,
        InterestLevel: 2,
        SalesOpportunitiesLines: [
            {
                LineNum: 0,
                SalesPerson: record.inside_sales_owner_id, # Inside Sales
                StartDate: record.created_at.strftime('%F'),
                ClosingDate: record.created_at.strftime('%F'),
                StageKey: 1,
                PercentageRate: 1,
                MaxLocalTotal: record.potential_amount,
                Remarks: record.commercial_terms_and_conditions,
                Contact: "tNO",
                Status: "sos_Open",
                WeightedAmountLocal: 1,
                WeightedAmountSystem: 1,
                DocumentNumber: nil,
                DocumentType: "bodt_MinusOne",
                DocumentCheckbox: nil,
                ContactPerson: record.contact.remote_uid,
                BPChanelName: nil,
                BPChanelCode: nil,
                DataOwnershipfield: 307,
                BPChannelContact: nil
            }
        ],
        MaxLocalTotal: record.potential_amount
    }

  end

end