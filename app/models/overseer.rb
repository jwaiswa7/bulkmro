class Overseer < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsAPerson

  has_closure_tree({ name_column: :to_s })

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  enum role: { admin: 10, sales: 20 }

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.role ||= :admin
  end

  def hierarchy_to_s
    ancestry_path.join(' > ')
  end
end
