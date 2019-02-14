# frozen_string_literal: true

class ProductRejection < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :product
  belongs_to :comment, class_name: 'ProductComment', foreign_key: :product_comment_id

  
end
