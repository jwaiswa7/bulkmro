class Services::Overseers::PurchaseOrders::UpdateLogisticsOwner < Services::Shared::BaseService
  def initialize(company)
    @company = company
  end

  def call
    company.inquiries.joins(:purchase_orders).where('purchase_orders.logistics_owner_id = ?', nil).each do |po|
      po.update_attributes(logistics_owner_id: company.logistics_owner_id)
      po.inward_dispatches.where(logistics_owner_id: nil).each do |inward_dispatch|
        inward_dispatch.update_attributes(logistics_owner_id: company.logistics_owner_id)
      end
    end
  end

  private
    attr_accessor :company
end
