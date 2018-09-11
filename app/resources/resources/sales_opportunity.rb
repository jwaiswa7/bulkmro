class Resources::SalesOpportunity < Resources::ApplicationResource

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

    return {
        "CardCode": record.contact.id,
        "U_SalesMgr": "No Sales Manager",
        "StartDate": record.created_at.strftime('%F'),
        "MaxSystemTotal": 0.01,
        "ProjectCode": record.project_uid,
        "Status": "sos_Open",
        "PredictedClosingDate": (record.created_at + 2.months).strftime('%F') ,
        "OpportunityName": "Pendrive",
        "InterestLevel": 2,
        "SalesOpportunitiesLines": [
            {
                "LineNum": 0,
                "SalesPerson": 163, # Inside Sales
                "StartDate": record.created_at.strftime('%F'),
                "ClosingDate": record.created_at.strftime('%F'),
                "StageKey": 1,

                "PercentageRate": 1,
                "MaxLocalTotal": 0.01,
                "Remarks": nil,
                "Contact": "tNO",
                "Status": "sos_Open",
                "WeightedAmountLocal": 1,
                "WeightedAmountSystem": 0.02,
                "DocumentNumber": nil,
                "DocumentType": "bodt_MinusOne",
                "DocumentCheckbox": nil,
                "ContactPerson": 3,
                "BPChanelName": nil,
                "BPChanelCode": nil,
                "DataOwnershipfield": 307,
                "BPChannelContact": nil
            }
        ],
        "MaxLocalTotal": 0.01
    }

  end

end