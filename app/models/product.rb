class Product < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeApproved
  include Mixins::CanBeTrashed

  pg_search_scope :locate, :against => [:sku, :name], :associated_against => { brand: [:name] }, :using => { :tsearch => { :prefix => true } }

  belongs_to :brand
  belongs_to :category
  belongs_to :import_row, :class_name => 'InquiryImportRow', foreign_key: :inquiry_import_row_id, required: false
  has_many :product_suppliers, dependent: :destroy
  has_many :inquiry_products, :dependent => :destroy
  has_one :approval, :class_name => 'ProductApproval', inverse_of: :product, dependent: :destroy
  accepts_nested_attributes_for :approval
  has_many :p_suppliers, :through => :product_suppliers, class_name: 'Company', source: :supplier
  has_many :b_suppliers, :through => :brand, class_name: 'Company', source: :suppliers
  has_many :comments, :class_name => 'ProductComment'
  accepts_nested_attributes_for :comments

  def c_suppliers
    Company.joins(:category_suppliers).where('category_id IN (?)', self.category.self_and_descendants.map(&:id))
  end

  def suppliers
    Company.where('id in (?)', p_suppliers.pluck(:id) + c_suppliers.pluck(:id) + b_suppliers.pluck(:id)).uniq
  end

  validates_presence_of :name
  validates_presence_of :sku, :if => :not_trashed?
  validates_uniqueness_of :sku, :if => :not_trashed?

  scope :approved, -> { joins(:approval).where.not(product_approvals: {id: nil }) }
  scope :not_approved, -> { joins(:approval).where(product_approvals: {id: nil }) }

  def to_s
    "#{name} (#{sku || trashed_uid})"
  end

  def disapproved?
    false
  end
end
