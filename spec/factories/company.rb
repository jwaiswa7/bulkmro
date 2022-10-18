FactoryBot.define do
  factory :company do
    association :account
    association :industry
    name { Faker::Company.name }
    pan { "HUHUH00000"}
  end
end