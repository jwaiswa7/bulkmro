class CreatePaymentCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_collections do |t|
      t.references :account
      t.references :company

      t.decimal :amount_received_on_account, default: 0.0
      t.decimal :amount_received_against_invoice, default: 0.0
      t.decimal :total_amount_received, default: 0.0
      t.decimal :amount_outstanding, default: 0.0

      t.decimal :amount_received_fp_nd, default: 0.0
      t.decimal :amount_received_pp_nd, default: 0.0
      t.decimal :amount_received_npr_nd, default: 0.0

      t.decimal :amount_received_fp_od, default: 0.0
      t.decimal :amount_received_pp_od, default: 0.0
      t.decimal :amount_received_npr_od, default: 0.0

      t.decimal :amount_outstanding_pp_nd, default: 0.0
      t.decimal :amount_outstanding_npr_nd, default: 0.0

      t.decimal :amount_outstanding_pp_od, default: 0.0
      t.decimal :amount_outstanding_npr_od, default: 0.0

      t.decimal :amount_1_to_30_od, default: 0.0
      t.decimal :amount_31_to_60_od, default: 0.0
      t.decimal :amount_61_to_90_od, default: 0.0
      t.decimal :amount_more_90_od, default: 0.0

      t.decimal :amount_1_to_7_nd, default: 0.0
      t.decimal :amount_8_to_15_nd, default: 0.0
      t.decimal :amount_15_to_30_nd, default: 0.0
      t.decimal :amount_more_30_nd, default: 0.0

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
