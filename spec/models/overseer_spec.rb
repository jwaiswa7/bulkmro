require 'rails_helper'

RSpec.describe Overseer, type: :model do
  let(:overseer) { FactoryBot.build :overseer }

  it "is a valid record" do 
    expect(overseer).to be_valid 
  end

  it "is not valid without an email" do 
    overseer.email = nil 
    expect(overseer).not_to be_valid
  end

  it "is not valid without a password" do 
    overseer.password = nil 
    expect(overseer).not_to be_valid
  end
end
