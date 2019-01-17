class CompanyCreationRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasApproveableStatus


  belongs_to :activity
  belongs_to :account
  has_one :company
  validates_presence_of :name
  pg_search_scope :locate, :against => [:name], :associated_against => {}, :using => {:tsearch => {:prefix => true}}

  scope :requested, -> {where(:company_id => nil)}
  scope :created, -> {where.not(:company_id => nil)}


  enum :account_type => {
      :is_supplier => 10,
      :is_customer => 20,
  }

  def status
    (self.account_id.present? && self.company_id.present?) ? 'created' : 'Requested'
  end

end