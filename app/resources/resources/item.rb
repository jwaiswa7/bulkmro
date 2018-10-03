class Resources::Item < Resources::ApplicationResource

  def self.identifier
    :ItemCode
  end

  def self.to_remote(record)

    params = {}

    if record.is_service
      params['SACEntry'] = record.tax_code.try(:remote_uid) * -1
      params['ManageBatchNumbers'] = "tNO"
      params['InventoryItem'] = 'tNO'
      params['MaterialType'] = "mt_FinishedGoods"

    else
      params['InventoryItem'] = 'tYES'
      params['ManageBatchNumbers'] = 'tYES'
      params['ChapterID'] = record.tax_code.try(:remote_uid)
      params['MaterialType'] = 3
    end

    {
        ItemCode: record.sku, # BMRO Part#
        ItemName: record.name, # Product Name
        ItemsGroupCode: record.category.remote_uid, # Product Category
        PurchaseItem: "tYES", #TO BE CREATED IN MAGENTO
        SalesItem: "tYES", #TO BE CREATED IN MAGENTO
        Mainsupplier: nil, #Supplier ID
        Manufacturer: -1, #Product Manufacturer
        Valid: "tYES", #Status
        SalesUnit: nil, #TO BE CREATED IN MAGENTO
        SalesItemsPerUnit: 1, #UOM Quantity
        PurchaseUnit: nil, #TO BE CREATED IN MAGENTO
        PurchaseItemsPerUnit: 1, #TO BE CREATED IN MAGENTO
        PurchaseUnitWeight: 0, #TO BE CREATED IN MAGENTO
        SalesUnitWeight1: 0, #weight
        SWW: record.try(:mpn), #MPN
        LeadTime: nil, #Delivery Period
        MinOrderQuantity: 0, #Minimum Order Qty
        InventoryUOM: record.measurement_unit.try(:name), #
        InventoryWeight1: 0, #Weight
        U_Category: record.category.remote_uid, #????
        U_ProdID: record.to_param, #Product Id
        U_MRP: 0, #MRP Price
        U_DistAmt: 0, #Distributor Discount
        U_SellPrice: 0, #Selling Price
        U_ProdSource: nil, #Imported or Local
        U_CntryOfOrgn: nil, #Country of Origin
        U_Meta_Dscrpt: record.meta_description, #Meta Description
        U_Meta_Title: record.meta_title, #Meta Title
        U_Attribute: nil, #Attribute Set Name
        U_ShortName: nil, #Product Short Name
        U_MOQIncrement: 0, #MOQ Increment
        U_Item_Descr: record.description, #Product Description
        U_SubCat: nil, #Subcategory 1
        U_SubCat2: nil, #Subcategory 2
        U_Meta_Key: record.meta_keyword, #Meta Keyword
        SACEntry: params['SACEntry'],
        InventoryItem: params['InventoryItem'],
        ManageBatchNumbers: params['ManageBatchNumbers'],
        ChapterID: params['ChapterID'],
        MaterialType: params['MaterialType'],
        GSTRelevnt: "tYES",
        GSTTaxCategory: "gtc_Regular",
        U_TaxClass: record.tax_code.tax_percentage.to_i, #Tax Class
    }
  end


  def self.create(record)
    OpenStruct.new(post("/#{collection_name}", body: to_remote(record).to_json).parsed_response)
  end

  def self.update(id, record, options = {})
    response = patch("/#{collection_name}('#{id}')", body: to_remote(record).to_json)
    get_validated_response(:patch, record, response)
    id
  end
end