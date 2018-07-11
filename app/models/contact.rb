class Contact < ApplicationRecord
  belongs_to :account
  has_many :inquiries
end
