FactoryBot.define do
  factory :currency do 
    conversion_rate { rand(0.1..0.6).round(2) }
    name {  ["USD", "INR", "EUR", "LEI"].sample }
  end
end