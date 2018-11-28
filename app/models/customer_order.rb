class CustomerOrder < ApplicationRecord
  belongs_to :contact
  belongs_to :company
  has_many :rows, dependent: :destroy, class_name: 'CustomerOrderRow'


  def total_quantities
    self.rows.pluck(:quantity).inject(0) {|sum, x| sum + x}
  end

end
