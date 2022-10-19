require 'rails_helper'

RSpec.describe InquiryCurrency, type: :model do
  
  let(:inquiry_currency) { FactoryBot.build :inquiry_currency}

  it "is a valid record" do 
    expect(inquiry_currency).to be_valid   
  end

  it "is not valid without a currency" do 
    inquiry_currency.currency = nil 
    expect(inquiry_currency).not_to be_valid
  end 

  it "is not valid without a conversion rate" do 
    inquiry_currency.conversion_rate = nil 
    expect(inquiry_currency).not_to be_valid
  end
end
