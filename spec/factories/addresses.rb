FactoryBot.define do
  factory :address do
    association :state, factory: :address_state
  end
end