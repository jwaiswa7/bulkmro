class CompanyBrand < ApplicationRecord
  belongs_to :company
  belongs_to :brand
end
