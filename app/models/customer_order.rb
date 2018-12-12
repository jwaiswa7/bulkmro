class CustomerOrder < ApplicationRecord
  pg_search_scope :locate, :against => [:id], :associated_against => {company: [:name] }, :using => {:tsearch => {:prefix => true}}

  belongs_to :contact
  belongs_to :company
  belongs_to :inquiry, required: false
  has_many :rows, dependent: :destroy, class_name: 'CustomerOrderRow'
  belongs_to :billing_address, -> (record) {where(company_id: record.company_id)}, class_name: 'Address', foreign_key: :billing_address_id, required: false
  belongs_to :shipping_address, -> (record) {where(company_id: record.company_id)}, class_name: 'Address', foreign_key: :shipping_address_id, required: false

  def to_s
    super.gsub!('CustomerOrder', 'Order')
  end

  def total_quantities
    self.rows.pluck(:quantity).inject(0) {|sum, x| sum + x}
  end
end
