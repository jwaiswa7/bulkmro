FactoryBot.define do
  factory :overseer do 
    email { "#{Faker::Internet.username}@bulkmro.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end