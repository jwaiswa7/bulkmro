require 'rails_helper'

RSpec.describe "Overseers::Inquiries", type: :request do


  describe "GET /index" do
    
    let(:admin_overseer) { FactoryBot.create :admin_overseer }

    it "user can't  access the index page without signing in" do 
      get overseers_inquiries_path
      expect(response).to have_http_status(302)
    end

    it "signed in overseer has access to the index page" do 
      sign_in admin_overseer
      get overseers_inquiries_path
      expect(response).to have_http_status(200)
    end
  end
end
