class AddressState < ApplicationRecord
  include Mixins::HasUniqueName

  scope :indian, -> { where(country_code: 'IN') }
  scope :not_indian, -> { where.not(country_code: 'IN') }
end
