class AddColumnsToFreightQuote < ActiveRecord::Migration[5.2]
  def change
    add_column :freight_quotes, :freight_amount, :decimal
    add_column :freight_quotes, :insurance, :decimal
    add_column :freight_quotes, :insurance_percentage, :decimal
    add_column :freight_quotes, :other_charges, :decimal
    add_column :freight_quotes, :basic_custom_duty, :decimal
    add_column :freight_quotes, :basic_custom_duty_percentage, :decimal
    add_column :freight_quotes, :duty_on_freight, :decimal
    add_column :freight_quotes, :duty_on_freight_percentage, :decimal
    add_column :freight_quotes, :social_welfare_cess, :decimal
    add_column :freight_quotes, :social_welfare_cess_percentage, :decimal
    add_column :freight_quotes, :custom_duty, :decimal
    add_column :freight_quotes, :gst, :decimal
    add_column :freight_quotes, :gst_percentage, :decimal
    add_column :freight_quotes, :grand_total, :decimal
    add_column :freight_quotes, :exchange_rate, :decimal
    add_column :freight_quotes, :buying_price, :decimal
    add_column :freight_quotes, :buying_price_inr, :decimal
    add_column :freight_quotes, :bank_charges, :decimal
    add_column :freight_quotes, :clearance, :decimal
    add_column :freight_quotes, :outward_freight, :decimal
    add_column :freight_quotes, :total_buying_price, :decimal
    add_column :freight_quotes, :selling_price_inr, :decimal
    add_column :freight_quotes, :margin, :decimal
    add_column :freight_quotes, :margin_value, :decimal

    add_column :freight_quotes, :origin_country, :string
    add_column :freight_quotes, :supplier, :string
    add_column :freight_quotes, :owner, :string
    add_column :freight_quotes, :customer, :string
    add_column :freight_quotes, :port_of_loading, :string
    add_column :freight_quotes, :port_of_discharge, :string
    add_column :freight_quotes, :currency, :string

    add_column :freight_quotes, :iec_code, :integer
    add_column :freight_quotes, :supplier_id, :integer

    add_reference :freight_quotes, :inquiry, foreign_key: true
    add_reference :freight_quotes, :purchase_order, foreign_key: true
  end
end
