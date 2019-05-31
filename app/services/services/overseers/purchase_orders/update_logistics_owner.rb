class Services::Overseers::PurchaseOrders::UpdateLogisticsOwner < Services::Shared::BaseService
  def initialize(company, current_overseer)
    @company = company
    @current_overseer = current_overseer
    @logistics_owner_name = company.logistics_owner.name
  end

  def call
    PurchaseOrder.with_inquiry_by_company(company.id).with_all_material_statuses.each do |po|
      po.update_attributes(logistics_owner_id: company.logistics_owner_id)
      po.comments.create(message: "Logistics Owner Set to #{logistics_owner_name}", overseer: current_overseer)
      po.save

      po.inward_dispatches.each do |inward_dispatch|
        inward_dispatch.update_attributes(logistics_owner_id: company.logistics_owner_id)
        inward_dispatch.comments.create(message: "Logistics Owner Set to #{logistics_owner_name}", overseer: current_overseer)
        inward_dispatch.save
      end
    end
  end

  private
    attr_accessor :company, :current_overseer, :logistics_owner_name
end
