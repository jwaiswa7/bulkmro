FactoryBot.define do
  factory :contact do
    association :account
    email { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number  }
  end
end