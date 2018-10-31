class Resources::Item < Resources::ApplicationResource

  def self.identifier
    :ItemCode
  end

  def self.update(id, record)
    super(id, record, quotes: true)
  end

  def self.to_remote(record)
    params = {
        ItemCode: record.sku, #  BMRO Part#
        ItemName: record.name[0..99], # Product Name
        ItemsGroupCode: (record.category.present? && record.category.remote_uid.present?) ? record.category.remote_uid : 100, #record.category.remote_uid, # Product Category
        PurchaseItem: "tYES", # TO BE CREATED IN MAGENTO
        SalesItem: "tYES", # TO BE CREATED IN MAGENTO
        Mainsupplier: nil, # Supplier ID
        Manufacturer: (record.brand.present? && record.brand.remote_uid.present?) ? record.brand.remote_uid : -1, # Product Manufacturer
        Valid: "tYES", # Status
        SalesUnit: nil, # TO BE CREATED IN MAGENTO
        SalesItemsPerUnit: 1, # UOM Quantity
        PurchaseUnit: nil, # TO BE CREATED IN MAGENTO
        PurchaseItemsPerUnit: 1, # TO BE CREATED IN MAGENTO
        PurchaseUnitWeight: 0, # TO BE CREATED IN MAGENTO
        SalesUnitWeight1: 0, # weight
        SWW: record.try(:mpn), # MPN
        LeadTime: nil, # Delivery Period
        MinOrderQuantity: 0, # Minimum Order Qty
        InventoryUOM: record.measurement_unit.try(:name), #
        InventoryWeight1: 0, # Weight
        U_Category: (record.category.present? && record.category.remote_uid.present?) ? record.category.remote_uid : 100, #record.category.remote_uid, # ????
        U_ProdID: record.to_param, # Product Id
        U_MRP: 0, # MRP Price
        U_DistAmt: 0, # Distributor Discount
        U_SellPrice: 0, # Selling Price
        U_ProdSource: nil, # Imported or Local
        U_CntryOfOrgn: nil, # Country of Origin
        U_Meta_Dscrpt: record.meta_description, # Meta Description
        U_Meta_Title: record.meta_title, # Meta Title
        U_Attribute: nil, # Attribute Set Name
        U_ShortName: record.name, # Product Short Name
        U_MOQIncrement: 0, # MOQ Increment
        U_Item_Descr: record.name, # Product Description
        U_SubCat: nil, # Subcategory 1
        U_SubCat2: nil, # Subcategory 2
        U_Meta_Key: record.meta_keyword, # Meta Keyword
        GSTRelevnt: "tYES",
        GSTTaxCategory: "gtc_Regular",
        U_TaxClass: record.best_tax_rate.tax_percentage.to_i, # Tax Class
    }

    if record.is_service
      params.merge!({
                        SACEntry: record.best_tax_code.try(:remote_uid),
                        ManageBatchNumbers: "tNO",
                        InventoryItem: 'tNO',
                        MaterialType: "mt_FinishedGoods"
                    })
    else
      params.merge!({
                        InventoryItem: 'tYES',
                        ManageBatchNumbers: 'tYES',
                        ChapterID: record.best_tax_code.try(:remote_uid),
                        MaterialType: 3
                    })
    end

    params
  end
end