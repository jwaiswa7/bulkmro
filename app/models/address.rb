class Address < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasCountry
  include Mixins::CanBeSynced
  include Mixins::HasMobileAndTelephone

  include DisplayHelper

  update_index('addresses#address') {self}
  pg_search_scope :locate, against: [:name, :country_code, :street1, :street2, :state_name, :city_name, :pincode, :gst], associated_against: {state: [:name]}, using: {tsearch: {prefix: true}}

  belongs_to :state, class_name: 'AddressState', foreign_key: :address_state_id, required: false
  belongs_to :company, required: false
  belongs_to :cart, required: false
  belongs_to :customer_order, required: false
  has_one :warehouse
  has_one :as_default_billing_address, dependent: :nullify, class_name: 'Company', inverse_of: :default_billing_address, foreign_key: :default_billing_address_id
  has_one :as_default_shipping_address, dependent: :nullify, class_name: 'Company', inverse_of: :default_shipping_address, foreign_key: :default_shipping_address_id
  has_one :sales_order, as: :billing_address, dependent: :nullify
  has_one :sales_order, as: :shipping_address, dependent: :nullify
  has_one :po_request, as: :bill_to
  has_one :po_request, as: :ship_to

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

  scope :has_company_id, -> {where.not(company_id: nil)}
  scope :with_includes, -> {includes(:state, :company)}

  # validates_presence_of :name, :country_code, :city_name, :street1
  # validates_presence_of :pincode, :state, :if => :domestic?
  # validates_presence_of :state_name, :if => :international?
  validates_presence_of :state
  validates_uniqueness_of :remote_uid, on: :update, if: Proc.new {|address| address.company_id.present?}
  validates_length_of :gst, maximum: 15, minimum: 15, allow_nil: true, allow_blank: true, if: -> {self.gst != 'No GST Number'}
  # validates_presence_of :remote_uid

  validates_with FileValidator, attachment: :gst_proof, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :cst_proof, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :vat_proof, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :excise_proof, file_size_in_megabytes: 2

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.is_sez ||= false
    self.country_code ||= 'IN'
    if self.company.present?
      self.name ||= self.company.name
    end
  end

  after_create :set_remote_uid, if: :persisted? # Do not remove IMP for SAP
  after_initialize :set_remote_uid, if: :persisted?

  def set_remote_uid
    self.update_attributes(remote_uid: Services::Resources::Shared::UidGenerator.address_uid(self)) if self.remote_uid.blank?
  end

  def remove_gst_whitespace
    if self.gst != 'No GST Number' && self.gst != nil
      self.gst = self.gst.delete(' ')
    end
  end

  def syncable_identifiers
    [:billing_address_uid, :shipping_address_uid]
  end

  def self.legacy
    find_by_name('Legacy Indian State')
  end

  def to_s
    if self.warehouse.present?
      [self.warehouse.to_s, street1, street2, city_name, pincode, state.to_s, state_name, country_name].reject(&:blank?).join(', ')
    else
      [street1, street2, city_name, pincode, state.to_s, state_name, country_name].reject(&:blank?).join(', ')
    end
  end

  def to_multiline_s
    [
        street1,
        street2,
        [city_name, pincode].reject(&:blank?).join(', '),
        [state.to_s, country_name].reject(&:blank?).join(', ')
    ].reject(&:blank?).join('<br>').html_safe
  end

  def to_compact_multiline_s
    [
        street1,
        street2,
        [city_name, pincode, state.to_s, country_name].reject(&:blank?).join(', ')
    ].reject(&:blank?).join('<br>').html_safe
  end

  def footer
    [city_name, pincode, state.to_s, country_name].reject(&:blank?).join(', ').html_safe
  end

  def validate_gst
    if self.gst.present? && self.company.present?
      self.gst.match?(/^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/) || self.international? || self.company.is_unregistered_dealer
    else
      false
    end
  end

  def readable_gst
    if self.international?
      'International'
    elsif self.company.is_unregistered_dealer
      'URD'
    else
      gst
    end
  end
end
