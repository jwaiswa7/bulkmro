# frozen_string_literal: true

class CompanyCreationRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasApproveableStatus

  pg_search_scope :locate, against: [:name], associated_against: {}, using: { tsearch: { prefix: true } }

  belongs_to :activity
  belongs_to :company

  scope :requested, -> { where(company_id: nil) }
  scope :created, -> { where.not(company_id: nil) }

  enum account_type: {
      is_supplier: 10,
      is_customer: 20,
  }, _prefix: true


  def status
    (self.company_id.present?) ? 'created' : 'Requested'
  end

  def is_customer?
    self.account_type == 'is_customer'
  end
  def is_supplier?
    self.account_type == 'is_supplier'
  end
end
