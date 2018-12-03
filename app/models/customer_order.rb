class CustomerOrder < ApplicationRecord
  pg_search_scope :locate, :against => [:id], :associated_against => {company: [:name] }, :using => {:tsearch => {:prefix => true}}

  belongs_to :contact
  belongs_to :company
  belongs_to :inquiry, required: false
  has_many :rows, dependent: :destroy, class_name: 'CustomerOrderRow'

  def total_quantities
    self.rows.pluck(:quantity).inject(0) {|sum, x| sum + x}
  end
end
