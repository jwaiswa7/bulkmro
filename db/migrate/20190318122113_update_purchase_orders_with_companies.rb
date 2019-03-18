class UpdatePurchaseOrdersWithCompanies < ActiveRecord::Migration[5.2]
  def up
    Services::Shared::Migrations::AddCompanyToPurchaseOrder.new.call
  end
end
