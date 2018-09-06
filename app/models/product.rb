class Product < ApplicationRecord
  COMMENTS_CLASS = 'ProductComment'
  REJECTIONS_CLASS = 'ProductRejection'
  APPROVALS_CLASS = 'ProductApproval'

  include Mixins::CanBeStamped
  include Mixins::CanBeApproved
  include Mixins::CanBeRejected
  include Mixins::HasApproveableStatus
  include Mixins::HasComments

  pg_search_scope :locate, :against => [:sku, :name], :associated_against => { brand: [:name] }, :using => { :tsearch => { :prefix => false, :any_word => true } }

  belongs_to :brand
  belongs_to :category
  belongs_to :inquiry_import_row, required: false
  has_one :import, :through => :inquiry_import_row, class_name: 'InquiryImport'
  has_one :inquiry, :through => :import
  has_many :product_suppliers, dependent: :destroy
  has_many :inquiry_products, :dependent => :destroy
  has_many :inquiry_product_suppliers, :through => :inquiry_products
  has_many :suppliers, :through => :inquiry_product_suppliers, class_name: 'Company', source: :supplier

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

  enum type: { item: 0, service: 1 }

  validates_presence_of :name
  validates_presence_of :sku, :if => :not_rejected?
  validates_uniqueness_of :sku, :if => :not_rejected?

  def to_s
    "#{name} (#{sku || trashed_sku })"
  end

  def lowest_inquiry_product_supplier
    self.inquiry_product_suppliers.order(:unit_cost_price => :asc).first
  end

  def latest_inquiry_product_supplier
    self.inquiry_product_suppliers.latest_record
  end

  def lowest_unit_cost_price
    lowest_inquiry_product_supplier.unit_cost_price if lowest_inquiry_product_supplier.present?
  end

  def latest_unit_cost_price
    latest_inquiry_product_supplier.unit_cost_price if latest_inquiry_product_supplier.present?
  end

  def lowest_unit_cost_price_for(supplier, except=nil)
    self.inquiry_product_suppliers.except_object(except).where(:supplier => supplier).order(:unit_cost_price => :asc).first.try(:unit_cost_price) || 'N/A'
  end

  def latest_unit_cost_price_for(supplier, except=nil)
    self.inquiry_product_suppliers.except_object(except).where(:supplier => supplier).latest_record.try(:unit_cost_price) || 'N/A'
  end
end