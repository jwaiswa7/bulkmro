class CreatePaymentCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_collections do |t|
        t.references :account
        t.references :company

        t.decimal :amount_received_on_account
        t.decimal :amount_received_against_invoice
        t.decimal :total_amount_received
        t.decimal :amount_outstanding

        t.decimal :amount_received_fp_nd
        t.decimal :amount_received_pp_nd
        t.decimal :amount_received_npr_nd

        t.decimal :amount_received_fp_od
        t.decimal :amount_received_pp_od
        t.decimal :amount_received_npr_od

        t.decimal :amount_outstanding_pp_nd
        t.decimal :amount_outstanding_npr_nd

        t.decimal :amount_outstanding_pp_od
        t.decimal :amount_outstanding_npr_od

        t.userstamps
        t.timestamps

        # FP: Full Paid
        # PP: Partially Paid
        # NPR: No Payment Received
        # ND: Not Due
        # OD: Over Due
    end
  end
end
