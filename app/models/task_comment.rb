class TaskComment < ApplicationRecord

  include Mixins::CanBeStamped

  belongs_to :task
  has_many_attached :attachments

  belongs_to :tag_user, -> { order(:first_name) }, class_name: 'Overseer', foreign_key: 'tag_user_id', required: false


  validates_presence_of :message

  def author
    self.created_by
  end

  def author_role
    author.role.titleize
  end


end

