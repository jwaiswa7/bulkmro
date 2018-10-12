class Address < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasCountry
  include Mixins::CanBeSynced

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  belongs_to :state, class_name: 'AddressState', foreign_key: :address_state_id, required: false
  belongs_to :company, required: false
  has_one :warehouse
  has_one :as_default_billing_address, dependent: :nullify, class_name: 'Company', inverse_of: :default_billing_address, foreign_key: :default_billing_address_id
  has_one :as_default_shipping_address, dependent: :nullify, class_name: 'Company', inverse_of: :default_shipping_address, foreign_key: :default_shipping_address_id

  has_one_attached :gst_proof
  has_one_attached :cst_proof
  has_one_attached :vat_proof
  has_one_attached :excise_proof

  enum gst_type: {
      regular_tds_isd_regular_isd: 10,
      casual_taxable_person: 20,
      composition_levy: 30,
      psu_government_department_or_psu: 40,
      non_resident_taxable_person: 50,
      un_agency_or_embassy: 60,
  }

  # validates_presence_of :name, :country_code, :city_name, :street1
  # validates_presence_of :pincode, :state, :if => :domestic?
  # validates_presence_of :state_name, :if => :international?
  validates_presence_of :state, :if => :domestic?

  validates_presence_of :remote_uid
  validates_with FileValidator, attachment: :gst_proof, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :cst_proof, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :vat_proof, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :excise_proof, file_size_in_megabytes: 2

  validates_presence_of :telephone, if: -> { !self.mobile.present? && not_legacy? }
  validates_presence_of :mobile, if: -> { !self.telephone.present? && not_legacy? }
  phony_normalize :telephone, :mobile, default_country_code: 'IN', if: :not_legacy?
  validates_plausible_phone :telephone, :mobile, allow_blank:true, if: :not_legacy?

  after_initialize :set_defaults, :if => :new_record?
  after_initialize :set_global_defaults

  def set_defaults
    self.is_sez ||= false

    if self.company.present?
      self.name ||= self.company.name
    end
  end

  def set_global_defaults
    self.remote_uid ||= Services::Resources::Shared::UidGenerator.address_uid
  end

  def to_s
    [street1, street2, city_name, pincode, state.to_s, state_name, country_name].compact.join(', ')
  end

  def self.legacy
    find_by_name('Legacy Indian State')
  end
end