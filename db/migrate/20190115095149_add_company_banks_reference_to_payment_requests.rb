class AddCompanyBanksReferenceToPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_reference :payment_requests, :company_bank, foreign_key: true
  end
end
