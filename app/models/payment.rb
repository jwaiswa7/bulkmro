class Payment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :customer_order
  belongs_to :contact, required:false

  enum status: {
      :'created' => 10,
      :'authorized' => 20,
      :'captured' => 30,
      :'refunded' => 40,
      :'failed' => 50,
  }

end
