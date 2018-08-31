class Product < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeApproved
  include Mixins::CanBeRejected

  default_scope { not_rejected }
  pg_search_scope :locate, :against => [:sku, :name], :associated_against => { brand: [:name] }, :using => { :tsearch => { :prefix => true } }

  belongs_to :brand
  belongs_to :category
  belongs_to :import_row, :class_name => 'InquiryImportRow', foreign_key: :inquiry_import_row_id, required: false
  has_one :import, :through => :import_row, class_name: 'InquiryImport'
  has_one :inquiry, :through => :import
  has_many :product_suppliers, dependent: :destroy
  has_many :inquiry_products, :dependent => :destroy
  has_many :inquiry_suppliers, :through => :inquiry_products
  has_many :suppliers, :through => :inquiry_suppliers, class_name: 'Company', source: :supplier
  has_one :approval, :class_name => 'ProductApproval', inverse_of: :product, dependent: :destroy
  has_one :rejection, :class_name => 'ProductRejection', inverse_of: :product, dependent: :destroy

  has_many :comments, :class_name => 'ProductComment', dependent: :destroy
  has_one :last_comment, -> { order(created_at: :desc) }, class_name: 'ProductComment'
  accepts_nested_attributes_for :comments

  # Start ignore
  # has_many :p_suppliers, :through => :product_suppliers, class_name: 'Company', source: :supplier
  # has_many :b_suppliers, :through => :brand, class_name: 'Company', source: :suppliers
  # def c_suppliers
  #   Company.joins(:category_suppliers).where('category_id IN (?)', self.category.self_and_descendants.map(&:id))
  # end
  # def all_suppliers
  #   Company.where('id in (?)', p_suppliers.pluck(:id) + c_suppliers.pluck(:id) + b_suppliers.pluck(:id)).uniq
  # end
  # End ignore

  validates_presence_of :name
  validates_presence_of :sku, :if => :not_rejected?
  validates_uniqueness_of :sku, :if => :not_rejected?

  def to_s
    "#{name} (#{sku || trashed_sku })"
  end

  def self.rejections_table
    :product_rejections
  end

  def self.approvals_table
    :product_approvals
  end

  def lowest_inquiry_supplier
    self.inquiry_suppliers.order(:unit_cost_price => :asc).first
  end

  def latest_inquiry_supplier
    self.inquiry_suppliers.latest_record
  end

  def lowest_unit_cost_price
    lowest_inquiry_supplier.unit_cost_price if lowest_inquiry_supplier.present?
  end

  def latest_unit_cost_price
    latest_inquiry_supplier.unit_cost_price if latest_inquiry_supplier.present?
  end
end