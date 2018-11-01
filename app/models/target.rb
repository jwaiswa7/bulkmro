class Target < ApplicationRecord

  belongs_to :target_period, required: true
  belongs_to :overseer, required: true

  enum target_type: {
      :'Inquiry' => 10,
      :'Invoice' => 20,
      :'Invoice Margin' => 30,
      :'Order' => 40,
      :'Order Margin' => 50,
      :'New Client' => 60
  }

  validates_presence_of :target_value

  after_initialize :set_defaults
  def set_defaults
    self.target_value ||= 0
  end
end
