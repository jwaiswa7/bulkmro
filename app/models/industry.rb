# frozen_string_literal: true

class Industry < ApplicationRecord
  include Mixins::HasUniqueName
  include Mixins::CanBeSynced
end
