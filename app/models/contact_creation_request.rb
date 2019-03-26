class ContactCreationRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasApproveableStatus

  pg_search_scope :locate, against: [:name], associated_against: {}, using: { tsearch: { prefix: true } }

  belongs_to :activity
  belongs_to :company_creation_request

  scope :requested, -> { where(contact_id: nil) }
  scope :created, -> { where.not(contact_id: nil) }

  def status
    (self.contact_id.present?) ? 'created' : 'Requested'
  end
end
