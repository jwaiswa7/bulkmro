class Services::Overseers::Inquiries::LinkSuppliersToProducts < Services::Shared::BaseService
  def initialize(inquiry, supplier_ids, inquiry_product_ids)
    @inquiry = inquiry
    @supplier_ids = supplier_ids.map { |x| x.to_i }
    @inquiry_product_ids = inquiry_product_ids[0].split(',')
  end

  def call
    debugger
    inquiry_products = InquiryProduct.where(id: inquiry_product_ids)
    inquiry_products.each do |inquiry_product|
      if inquiry_product.product.approved?
        supplier_ids.each do |supplier_id|
          supplier = Company.find(supplier_id).to_s
          if supplier.to_s != 'Local'
            inquiry_product_supplier = InquiryProductSupplier.where(inquiry_product_id: inquiry_product.id, supplier_id: supplier_id).first_or_initialize
            if inquiry_product_supplier.save
              service = Services::Suppliers::CreateSupplierProduct.new(inquiry_product_supplier)
              service.call
            end
          end
        end
      end
    end
  end

  private

    attr_accessor :inquiry, :supplier_ids, :inquiry_product_ids
end
