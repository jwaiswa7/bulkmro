require 'rails_helper'

RSpec.describe Account, type: :model do
  let (:account) { FactoryBot.build :account }

  it "is a valid record" do 
    expect(account).to be_valid
  end

  it "is not valid without a name" do 
    account.name = nil
    expect(account).not_to be_valid  
  end
end
