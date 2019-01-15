class CompanySurvey < ApplicationRecord
  belongs_to :company
  belongs_to :invoice_request
  belongs_to :overseer
  belongs_to :po_request
  has_many :company_rating


  enum type:{
    :'Logistics' => 10,
    :'Sales' => 20
  }
end
