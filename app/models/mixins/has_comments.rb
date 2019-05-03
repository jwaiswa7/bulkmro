module Mixins::HasComments
  extend ActiveSupport::Concern

  included do
    has_many :comments, class_name: self::COMMENTS_CLASS, dependent: :destroy
    has_one :last_comment, -> { order(created_at: :desc) }, class_name: self::COMMENTS_CLASS
    accepts_nested_attributes_for :comments, reject_if: lambda { |attributes| attributes['message'].blank? }, allow_destroy: true
  end
end
