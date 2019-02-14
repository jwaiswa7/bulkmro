# frozen_string_literal: true

class Target < ApplicationRecord
  belongs_to :target_period, required: true
  belongs_to :overseer, required: true
  belongs_to :manager, class_name: 'Overseer', foreign_key: :manager_id, required: false
  belongs_to :business_head, class_name: 'Overseer', foreign_key: :business_head_id, required: false

  enum target_type: {
      'Inquiry': 10,
      'Invoice': 20,
      'Invoice Margin': 30,
      'Order': 40,
      'Order Margin': 50,
      'New Client': 60
  }

  validates_presence_of :target_value

  after_initialize :set_defaults
  def set_defaults
    self.target_value ||= 0
  end
end
