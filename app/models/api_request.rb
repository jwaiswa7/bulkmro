class ApiRequest < ApplicationRecord
  include Hashid::Rails
  serialize :payload 
end