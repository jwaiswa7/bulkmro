FactoryBot.define do
  factory :inquiry_currency do 
    association :currency
    conversion_rate { rand(0.1..0.6).round(2) }
  end
end