class Company < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasUniqueName
  include Mixins::HasManagers

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  belongs_to :account

  belongs_to :default_contact, class_name: 'CompanyContact', foreign_key: :default_contact_id, required: false
  belongs_to :default_payment_option, class_name: 'PaymentOption', foreign_key: :default_payment_option_id, required: false
  belongs_to :default_billing_address, class_name: 'Address', foreign_key: :default_billing_address_id, required: false
  belongs_to :default_shipping_address, class_name: 'Address', foreign_key: :default_shipping_address_id, required: false

  belongs_to :industry

  has_many :banks, class_name: 'CompanyBank', inverse_of: :company

  has_many :company_contacts
  has_many :contacts, :through => :company_contacts
  accepts_nested_attributes_for :company_contacts

  has_many :product_suppliers, foreign_key: :supplier_id
  has_many :products, :through => :product_suppliers
  accepts_nested_attributes_for :product_suppliers

  has_many :category_suppliers, foreign_key: :supplier_id
  has_many :categories, :through => :category_suppliers
  accepts_nested_attributes_for :category_suppliers

  has_many :brand_suppliers, foreign_key: :supplier_id
  has_many :brands, :through => :brand_suppliers
  has_many :brand_products, :through => :brands, :class_name => 'Product', :source => :products
  accepts_nested_attributes_for :brand_suppliers

  has_many :inquiries
  has_many :inquiry_product_suppliers, :through => :inquiries
  has_many :addresses

  has_one_attached :tan_proof
  has_one_attached :pan_proof
  has_one_attached :cen_proof

  # todo: implement
  # validates_content_type_of :tax_proof, %w('image/png application/pdf image/jpeg')
  # validates_fize_size_of :tax_proof, mb: 2
  # https://guides.rubyonrails.org/active_record_validations.html#custom-validators
  #
  # validate :proof_content_type
  # validate :proof_file_size
  #
  # def proof_content_type
  #   if proof.attached? && !proof.content_type.in?(%w(image/png application/pdf image/jpeg))
  #     errors.add(:document, 'Must be an image or a pdf file')
  #     proof.purge
  #   end
  # end
  #
  # def proof_file_size
  #   if proof.attached? && proof.blob.byte_size > 2097152
  #     errors.add(:document, 'Must be less than 2 MB in size')
  #     proof.purge
  #   end
  # end

  enum company_type: {
      :proprietorship => 10,
      :private_limited => 20,
      :contractor => 30,
      :trust => 40,
      :public_limited => 50
  }

  enum priority: {
      standard: 10,
      strategic: 20
  }

  enum nature_of_business: {
      trading: 10,
      manufacturer: 20,
      dealer: 30
  }

  # todo implement
  scope :acts_as_supplier, -> { }

  alias_attribute :gst, :tax_identifier
  validates_presence_of :tax_identifier  
  validates_uniqueness_of :tax_identifier
  validates_inclusion_of :is_msme, :in => [true, false]
  validates_inclusion_of :is_unregistered_dealer, :in => [true, false]

  delegate :mobile, :email, :telephone, to: :default_contact, allow_nil: true

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.company_type ||= :private_limited
    self.priority ||= :standard
    self.is_msme ||= false
    self.is_unregistered_dealer ||= false
  end

  def to_contextual_s(product)
    s = [self.to_s]

    if product.p_suppliers.include?(self)
      s.append('(Supplies product directly)')
    elsif product.c_suppliers.include?(self)
      s.append('(Supplies category)')
    else
      s.append('(Supplies brand)')
    end

    s.join(' ')
  end
end