class Resources::SalesOpportunity < Resources::ApplicationResource

  def self.identifier
    :SequentialNo
  end

  def self.to_remote(record)

=begin
Stage KEY
     '0' => 1,                    //1. Inquiry No. Assigned
        '2' => 2,                    //2. Acknowledgement Mail
        '3' => 3,                    //3. Cross Reference
        '4' => 5,                    //5. Prepare Quotation
        '5' => 6,                    //6. Quotation Sent
        '6' => 7,                    //7. Follow Up on Quotation
        '7' => 8,                    //8. Expected Order
        '8' => 12,                    //92. Won - SO Approved by Sales Manager
        '9' => 15,                    //96. Order Lost
        '10' => 16,                   //97. Regret
        '11' => 99,                   //0. Lead by O/S
        '12' => 4,                   //4. Supplier RFQ Sent
        '15' => 9,                   //4. Supplier RFQ Sent
        '18' => 14,
        '17' => 10,                     //95. SO Rejected by Sales Manager
        '19' => 12,                     //95. SO Rejected by Accounts
        '20' => 13,                     //95. SO Hold By Accounts
=end

    {
        CardCode: record.contact.remote_uid,
        U_SalesMgr: record.sales_manager.name,
        StartDate: record.created_at.strftime('%F'),
        MaxSystemTotal: record.potential_amount,
        ProjectCode: record.project_uid,
        Status: "sos_Open",
        PredictedClosingDate: (record.created_at + 2.months).strftime('%F') ,
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