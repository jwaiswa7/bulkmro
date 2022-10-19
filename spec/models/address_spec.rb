require 'rails_helper'

RSpec.describe Address, type: :model do

  let(:address) { FactoryBot.build :address }

  it "is a valid record" do 
    expect(address).to be_valid
  end

  it "is not valid without a state" do 
    address.state = nil 
    expect(address).not_to be_valid
  end
end
