class AddRateableReferenceToCompanyReview < ActiveRecord::Migration[5.2]
  def change
    add_reference :company_reviews, :rateable, polymorphic: true, index: true
  end
end
