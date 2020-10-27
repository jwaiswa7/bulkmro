class ApiRequest < ApplicationRecord
  include Hashid::Rails
  serialize :payload

  has_one :api_cart_response
end
