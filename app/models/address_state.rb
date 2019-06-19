# frozen_string_literal: true

class AddressState < ApplicationRecord
  include Mixins::HasUniqueName

  scope :indian, -> { where(country_code: 'IN').order(name: :asc) }
  scope :not_indian, -> { where.not(country_code: 'IN') }
end
