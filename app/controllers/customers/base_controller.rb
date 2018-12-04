class Customers::BaseController < ApplicationController
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  layout 'customers/layouts/application'

  before_action :authenticate_contact!
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized

  helper_method :current_cart, :current_contact_companies

  private

  def user_not_authorized
    message = "You are not authorized to perform this action."
    set_flash_message(message, :warning, now: false)
    redirect_to(request.referrer || root_path)
  end

  protected
  def policy!(user, record)
    CustomPolicyFinder.new(record, namespace).policy!.new(user, record)
  end

  def policy(record)
    policies[record] ||= policy!(pundit_user, record)
  end

  def pundit_policy_scope(scope)
    policy_scopes[scope] ||= policy_scope!(pundit_user, scope)
  end

  def policy_scope!(user, scope)
    CustomPolicyFinder.new(scope, namespace).scope!.new(user, scope).resolve
  end

  def current_cart
    current_contact.current_cart
  end

  def current_contact_companies
    current_contact.companies
  end

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
