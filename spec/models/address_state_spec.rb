require 'rails_helper'

RSpec.describe AddressState, type: :model do
  let(:address_state) { FactoryBot.build :address_state }

  it "is a valid record" do 
    expect(address_state).to be_valid
  end

  it "is not valid without a name" do 
    address_state.name = nil 
    expect(address_state).not_to be_valid
  end
end
