class BibleInvoice < ApplicationRecord
  belongs_to :company
  belongs_to :account
  belongs_to :sales_invoice, required: false
  belongs_to :inside_sales_owner, class_name: 'Overseer', foreign_key: 'inside_sales_owner_id', required: false
  belongs_to :outside_sales_owner, class_name: 'Overseer', foreign_key: 'outside_sales_owner_id', required: false

  enum branch_type: {
      'Gujarat': 10,
      'Maharashtra': 20,
      'Delhi': 30,
      'TamilNadu': 40,
      'Telangana': 50,
      'Bulk MRO USA': 60
  }

  enum invoice_type: {
      'Invoice': 10,
      'Credit Note': 20
  }
end
