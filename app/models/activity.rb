class Activity < ApplicationRecord
  include Mixins::CanBeStamped

  pg_search_scope :locate, :against => [:purpose, :company_type, :activity_type], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  has_many :activity_overseers
  has_many :overseers, :through => :activity_overseers
  accepts_nested_attributes_for :activity_overseers, reject_if: lambda { |attributes| attributes['overseer_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  belongs_to :inquiry, required: false
  belongs_to :company, required: false
  has_one :account, :through => :company
  belongs_to :contact, required: false

  enum company_type: {
      is_supplier: 10,
      is_customer: 20
  }

  enum purpose: {
      :'First Meeting/Intro Meeting' => 10,
      :'Follow up' => 20,
      :'Negotiation' => 30,
      :'Closure' => 40,
      :'Others' => 50,
  }

  enum activity_type: {
      :'meeting' => 10,
      :'phone_call' => 20,
      :'email' => 30,
      :'quote_tender_prep' => 40
  }

  scope :not_meeting, -> { where.not(activity_type: activity_types[:meeting]) }

  validates_presence_of :company_type
  validates_presence_of :purpose
  validates_presence_of :activity_type

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.company_type ||= :is_customer
    self.purpose ||= :'First Meeting/Intro Meeting'
    self.activity_type ||= :'Meeting'
  end

  def activity_company
    if self.company.present?
      self.company
    elsif self.inquiry.present?
      self.inquiry.company
    end
  end

  def activity_account
    if self.account.present?
      self.account
    elsif self.inquiry.present?
      self.inquiry.account
    end
  end

  def to_s
    (company || inquiry || contact).to_s
  end
end
