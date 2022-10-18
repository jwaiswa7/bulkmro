require 'rails_helper'

RSpec.describe Company, type: :model do
  
  let(:company) { FactoryBot.build :company }

  it "is a valid record" do 
    expect(company).to be_valid
  end

  it "is not valid without a name" do 
    company.name = nil 
    expect(company).not_to be_valid
  end

  it "is not valid without a pan" do 
    company.pan = nil 
    expect(company).not_to be_valid
  end

  it "has to be a valid pan" do 
    company.pan = "invalid"
    expect(company).not_to be_valid
  end
end
