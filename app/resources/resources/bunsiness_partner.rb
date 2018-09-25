class Resources::BusinessPartner < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.to_remote(record)
    {
        "CardCode": "SC-7419",#Company Code
        "CardName": "UNIVERSAL FLOWTECH ENGINEERS LLP.",#Company Name
        "CardType": "cSupplier",#
        "GroupCode": 101,#Company Alias
        "Address": "Office No.1, Shree Sai CHS., Plot No.20, Sector No.20, Kamothe,",#
        "ZipCode": "410209",#Company zipcode
        "Phone1": "9029482674",#Company Phone
        "Phone2": null,#
        "Fax": null,#
        "PayTermsGrpCode": 1,#
        "CreditLimit": 0,#
        "SalesPersonCode": -1,#
        "Currency": null,#
        "Cellular": null,#Company Mobile
        "City": "Navi Mumbai",#Company CIty
        "County": null,#
        "Country": "IN",#Company Country
        "EmailAddress": "sales@universalflowtech.com",#Customer Email ID
        "DefaultBranch": null,#
        "DefaultBankCode": "-1",#
        "ShippingType": null,#
        "IBAN": null,#
        "Block": null,#
        "ShipToDefault": "4159",#Default Shipping Address
        "BilltoDefault": "4159",#Default Billing Address
        "Territory": null,#Company Territory
        "GTSBankAccountNo": null,#
        "U_MSME": "No",#MSME
        "U_URD": "No",#URD
        "BPAddresses": [
            {
                "AddressName": "4159",#Company Billing Address
                "Street": "Office No.1, Shree Sai CHS., Plot No.20, Sector No.20, Kamothe,",#address
                "Block": null,#
                "ZipCode": "410209",#Company zipcode
                "City": "Navi Mumbai",#Company CIty
                "County": null,#
                "Country": "IN",#Company Country
                "State": "MH",#Company State
                "BuildingFloorRoom": null,#
                "AddressType": "bo_BillTo",#
                "AddressName2": null,#address
                "AddressName3": null,#address
                "StreetNo": null,#
                "GSTIN": "27AADFU8382N1ZD",#Company GST#
                "GstType": "gstRegularTDSISD",#
                "U_VAT": "",#Company VAT#
                "U_CST": ""#Company  CST#
            },
            {
                "AddressName": "4159",#Company Billing Address
                "Street": "Office No.1, Shree Sai CHS., Plot No.20, Sector No.20, Kamothe,",#address
                "Block": null,#
                "ZipCode": "410209",#Company zipcode
                "City": "Navi Mumbai",#Company CIty
                "County": null,#
                "Country": "IN",#Company Country
                "State": "MH",#Company State
                "BuildingFloorRoom": null,#
                "AddressType": "bo_ShipTo",#
                "AddressName2": null,#address
                "AddressName3": null,#address
                "StreetNo": null,#
                "GSTIN": "27AADFU8382N1ZD",#Company GST#
                "GstType": "gstRegularTDSISD",#
                "U_VAT": null,#Company VAT#
                "U_CST": null#Company  CST#
            }
        ],
        "ContactEmployees": [
            {
                "CardCode": "SC-7419",#CardCode
                "Name": "B.S. GAUTAM-849",#
                "Position": null,#Position
                "Address": null,#Address
                "Phone1": null,#Contact Person Phone
                "Phone2": null,#
                "MobilePhone": "9029482674",#Contact Person Phone
                "E_Mail": "sales@universalflowtech.com",#Contact Person EMail
                "Remarks1": "",#Customer Line Manager
                "DateOfBirth": null,#Date of Birth
                "Gender": "gt_Undefined",#Gender
                "Title": null,#Prefix (Mr / Mrs / Ms)
                "FirstName": "B.S.",#Contact Person First Name
                "MiddleName": null,#Contact Person Middle Name
                "LastName": "GAUTAM",#Contact Person Last Name
            }
        ],
        "BPFiscalTaxIDCollection": [
            {
                "Address": "",#Address
                "TaxId0": "AADFU8382N",#Company PAN#
                "TaxId3": null,#Company Service Tax
                "TaxId4": null,#Central Excise No.
                "TaxId5": null,#
                "TaxId6": null,#TAN
                "TaxId7": null,#
                "TaxId8": null,#company_type
                "TaxId9": "dealer",#nature_of_business
                "TaxId10": null,#
                "TaxId11": null,#Company VAT
            },
            {
                "Address": "4159",#
                "TaxId0": "AADFU8382N",#Company PAN#
                "TaxId3": null,#Company Service Tax
                "TaxId4": null,#Central Excise No.
                "TaxId5": null,#
                "TaxId6": null,#TAN
                "TaxId7": null,#
                "TaxId8": null,#company_type
                "TaxId9": "dealer",#nature_of_business
                "TaxId10": null,#
                "TaxId11": null,#Company VAT
            },
            {
                "Address": "4159",#
                "TaxId0": "AADFU8382N",#Company PAN#
                "TaxId3": null,#Company Service Tax
                "TaxId4": null,#Central Excise No.
                "TaxId5": null,#
                "TaxId6": null,#TAN
                "TaxId7": null,#
                "TaxId8": null,#company_type
                "TaxId9": "dealer",#nature_of_business
                "TaxId10": null,#
                "TaxId11": null,#Company VAT
            }
        ],
    }
  end
end