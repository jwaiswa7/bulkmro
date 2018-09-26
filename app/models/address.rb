class Address < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasCountry

  belongs_to :state, class_name: 'AddressState', foreign_key: :address_state_id, required: false
  belongs_to :company, required: false
  belongs_to :warehouse, required: false
  # has_one :inquiry

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

  validates_with FileValidator, attachment: :gst_proof, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :cst_proof, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :vat_proof, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :excise_proof, file_size_in_megabytes: 2

  def to_s
    [street1, street2, city_name, pincode, state.to_s, state_name, country_name].compact.join(', ')
  end

  def remote_uid
    self.legacy_id.present? ? self.legacy_id : "A#{self.id}"
  end

end