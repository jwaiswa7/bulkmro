class Contact < ApplicationRecord
  include Mixins::HasName

  belongs_to :account
  has_many :inquiries
end
