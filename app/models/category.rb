class Category < ApplicationRecord
  include Mixins::CanBeStamped

  has_closure_tree

  belongs_to :parent, :class_name => 'Category', :foreign_key => 'parent_id', required: false
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

  scope :without_children, -> { left_outer_joins(:children).where(children: { id: nil }) }
  scope :with_children, -> { joins(:children) }

  validates_presence_of :name

  # todo restrict editing parent category options
  def to_s
    ancestry_path.join(' > ')
  end
end