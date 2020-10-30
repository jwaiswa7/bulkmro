class ApiCartResponse < ApplicationRecord
  include Hashid::Rails
  serialize :payload

  belongs_to :api_request
end