FactoryBot.define do
  factory :address_state do
    name { Faker::Address.city }
  end
end