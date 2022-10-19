FactoryBot.define do
  factory :inquiry do
    association :contact 
    association :billing_company, factory: :company 
    association :shipping_company, factory: :company 
    association :shipping_contact, factory: :contact
    association :inside_sales_owner, factory: :overseer
    association :outside_sales_owner, factory: :overseer
    association :billing_address, factory: :address 
    association :shipping_address, factory: :address
    association :company
    association :payment_option 
    association :inquiry_currency
    potential_amount { rand(100..1000) }
    expected_closing_date { Date.today + 1.month }
    valid_end_time { Time.now + 1.month }
    quote_category { 10 }
  end
end