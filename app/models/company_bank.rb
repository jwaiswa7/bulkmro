# frozen_string_literal: true

class CompanyBank < ApplicationRecord
  include Mixins::HasCountry

  belongs_to :company

  validates_presence_of :account_number, :street_address
  validates_presence_of :name, :email, :phone
  validates_presence_of :swift, if: :international?
end
