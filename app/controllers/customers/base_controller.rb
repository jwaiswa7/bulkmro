class Customers::BaseController < ApplicationController
  include Pundit
  layout 'customers/layouts/application'

  before_action :authenticate_contact!
  before_action :set_paper_trail_whodunnit

  protected

  def pundit_user
    current_contact
  end

  def stamping_user
    current_contact
  end

  def namespace
    controller_namespace.capitalize
  end

  def user_for_paper_trail
    current_contact.to_gid.to_s if current_contact.present?
  end

  def controller_namespace
    @controller_namespace ||= controller_path.split('/').first
  end
end
