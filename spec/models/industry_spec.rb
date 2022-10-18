require 'rails_helper'

RSpec.describe Industry, type: :model do
  let(:industry) { FactoryBot.build :industry }

  it "is a valid record" do 
    expect(industry).to be_valid
  end

  it "is not valid without a name" do 
    industry.name = nil
    expect(industry).not_to be_valid
  end
end
