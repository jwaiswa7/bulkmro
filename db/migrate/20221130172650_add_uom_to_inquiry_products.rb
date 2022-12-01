class AddUomToInquiryProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :inquiry_products,:measurement_unit, foreign_key: true
  end
end
