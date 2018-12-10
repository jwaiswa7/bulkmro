class Customers::BaseController < ApplicationController
  include Pundit
  @@current_company = nil
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  layout 'customers/layouts/application'

  before_action :authenticate_contact!
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized
  before_action :check_company

  helper_method :current_cart, :current_contact_companies, :current_company

  def check_company
    if params[:session_company_id].present?
      session[:current_company_id] = params[:session_company_id]
    elsif session[:current_company_id].nil?
      if current_contact.companies.size <= 1
        session[:current_company_id] = current_contact.companies.first.id
        redirect_to customers_dashboard_path
      else
        render 'shared/layouts/choose_company'
      end
    end
  end

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

  def current_company
    Company.find(session[:current_company_id]) if session[:current_company_id].present?
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
