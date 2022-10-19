require 'rails_helper'

RSpec.describe Inquiry, type: :model do

  let(:inquiry) { FactoryBot.build :inquiry }

  it "is a valid record" do 
    expect(inquiry).to be_valid
  end

  it "is not valid without a contact" do 
    inquiry.contact = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without a billing company" do 
    inquiry.billing_company = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without a shipping company" do 
    inquiry.shipping_company = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without a shipping contact" do 
    inquiry.shipping_contact = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without an inside sales owner" do 
    inquiry.inside_sales_owner = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without an outside sales owner" do 
    inquiry.outside_sales_owner = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without a billing address" do 
    inquiry.billing_address = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without a shipping address" do 
    inquiry.shipping_address = nil 
    expect(inquiry).not_to be_valid
  end


  it "is not valid without a company" do 
    inquiry.company = nil 
    expect(inquiry).not_to be_valid
  end


  it "is not valid without a payment option" do 
    inquiry.payment_option = nil 
    expect(inquiry).not_to be_valid
  end


  it "is not valid without an inquiry currency" do 
    inquiry.inquiry_currency = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without a potential amount" do 
    inquiry.potential_amount = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without an expected closing date" do 
    inquiry.expected_closing_date = nil 
    expect(inquiry).not_to be_valid
  end


  it "is not valid without a valid end time" do 
    inquiry.valid_end_time = nil 
    expect(inquiry).not_to be_valid
  end

  it "is not valid without a quote category" do 
    inquiry.quote_category = nil 
    expect(inquiry).not_to be_valid
  end


end