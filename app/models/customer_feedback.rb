class CustomerFeedback < ApplicationRecord
    validates :customer_email, :experience, presence: true

    enum experience: { 
        "Excellent": 0, 
        "Good": 1,
        "Fair": 2,
        "Dissatisfied": 3,
        "Very Poor": 4
    }

end
