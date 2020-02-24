class AddCommercialTermsInPoRequestAndPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :commercial_terms_and_conditions, :text, default: nil
  end
end
