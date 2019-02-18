# frozen_string_literal: true

module Mixins::HasClosureTree
  extend ActiveSupport::Concern

  included do
    has_closure_tree

    scope :except_self_and_children, ->(obj) { where.not("#{model_name.collection}.id IN (?)", obj.self_and_descendants.pluck(:id)) if obj.present? }
  end
end
