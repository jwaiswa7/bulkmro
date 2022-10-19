require 'rails_helper'

RSpec.describe PaymentOption, type: :model do
  
  let(:payment_option) { FactoryBot.build :payment_option} 

  it "is a valid record" do 
    expect(payment_option).to be_valid   
  end

  it "is not valid without a name" do 
    payment_option.name = nil 
    expect(payment_option).not_to be_valid
  end
end
