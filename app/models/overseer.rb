class Overseer < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsAPerson

  has_one_attached :file

  pg_search_scope :locate, :against => [:first_name, :last_name, :email], :associated_against => { }, :using => { :tsearch => {:prefix => true} }
  has_closure_tree({ name_column: :to_s })

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  enum role: { admin: 10, sales: 20, sales_manager: 30 }

  validates_presence_of :email
  validates_presence_of :password, :if => :new_record?
  validates_presence_of :password_confirmation, :if => :new_record?

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.role ||= :admin
  end

  def hierarchy_to_s
    ancestry_path.join(' > ')
  end
end
