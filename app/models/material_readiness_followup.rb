class MaterialReadinessFollowup < ApplicationRecord
  COMMENTS_CLASS = 'MrfComment'

  include Mixins::HasComments

  belongs_to :purchase_order
  belongs_to :overseer
  has_many_attached :attachments

end
