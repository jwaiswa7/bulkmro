class Overseer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.role ||= :admin
  end

  enum role: {
      admin: 10,
      sales: 20
  }
end
