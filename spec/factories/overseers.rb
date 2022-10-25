FactoryBot.define do
  factory :overseer do 
    email { "#{Faker::Internet.username}@bulkmro.com" }
    password { "password" }
    password_confirmation { "password" }

    factory :admin_overseer do 
      role { "admin" }
      is_super_admin { true }
    end
  end
end