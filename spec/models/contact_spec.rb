require 'rails_helper'

RSpec.describe Contact, type: :model do
  let(:contact) { FactoryBot.build :contact}

  it "is a valid contact" do 
    expect(contact).to be_valid
  end

  it "is not valid without an email" do 
    contact.email = nil 
    expect(contact).not_to be_valid
  end

  it "is not valid without an telephone" do 
    contact.telephone = nil 
    expect(contact).not_to be_valid
  end
end
