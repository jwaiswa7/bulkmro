require 'rails_helper'

RSpec.describe Currency, type: :model do
  
  let(:currency) { FactoryBot.build :currency}

  it "is a valid record" do 
    expect(currency).to be_valid
  end

  it "is not valid without a conversion rate" do 
    currency.conversion_rate = nil 
    expect(currency).not_to be_valid
  end

  it "should have a numeric conversion rate" do 
    currency.conversion_rate = "test rate" 
    expect(currency).not_to be_valid
  end
end
