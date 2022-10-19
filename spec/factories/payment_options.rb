FactoryBot.define do
  factory :payment_option do
    name { Faker::Bank.name }
  end
end