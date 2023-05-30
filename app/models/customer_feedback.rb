class CustomerFeedback < ApplicationRecord
    validates :customer_email, :experience, presence: true

    enum experience: { 
      "Very poor": 0,
      "Poor": 1,
      "Fair": 2,
      "Good": 3,
      "Very good": 4,
      "Excellent": 5
    }

end