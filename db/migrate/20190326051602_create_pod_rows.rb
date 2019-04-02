class CreatePodRows < ActiveRecord::Migration[5.2]
  def change
    create_table :pod_rows do |t|
      t.string :attachments
      t.date :delivery_date
      t.references :sales_invoice, foreign_key: true

      t.timestamps
    end
  end
end
