class Customers::BaseController < ApplicationController
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  layout 'customers/layouts/application'

  before_action :authenticate_contact!
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized
  before_action :redirect_if_required

  helper_method :current_cart, :current_company

  private

  def render_pdf_for(record, locals={})
    render(
        pdf: record.filename,
        template: ['shared', 'layouts', 'pdf_templates', record.class.name.pluralize.underscore, 'show'].join('/'),
        layout: 'shared/layouts/pdf_templates/show',
        page_size: 'A4',
        footer: {
            center: '[page] of [topage]'
        },
        # show_as_html: true,
        locals: {
            record: record
        }.merge(locals)
    )
  end

  def redirect_if_required
    redirect_to_path = if session[:current_company_id].blank? || current_company.blank?
                         edit_current_company_customers_sign_in_steps_path
                       elsif session[:current_company_id].present? && current_company.present?
                         if params[:became].present? && current_contact.companies.pluck(:id).exclude?(current_company.id)
                           session[:current_company_id] = nil
                           edit_current_company_customers_sign_in_steps_path
                         elsif controller_name == 'sign_in_steps'
                           customers_dashboard_path
                         end
                       end

    redirect_to(redirect_to_path) if redirect_to_path.present? && request.path != redirect_to_path && request.method == 'GET'
  end

  def user_not_authorized
    message = "You are not authorized to perform this action."
    set_flash_message(message, :warning, now: false)
    redirect_to(request.referrer || root_path)
  end

  protected

  def policy!(user, current_company, record)
    CustomPolicyFinder.new(record, namespace).policy!.new(user, current_company, record)
  end

  def policy(record)
    policies[record] ||= policy!(pundit_user, current_company, record)
  end

  def pundit_policy_scope(scope)
    policy_scopes[scope] ||= policy_scope!(pundit_user, scope)
  end

  def policy_scope!(user, scope)
    CustomPolicyFinder.new(scope, namespace).scope!.new(user, scope).resolve
  end

  def current_cart
    current_contact.cart || current_contact.create_cart(
        company: current_company,
        billing_address: current_company.default_billing_address || current_company.billing_address.first,
        shipping_address: current_company.default_shipping_address || current_company.shipping_address.first,
    )
  end

  def current_company
    if session[:current_company_id].present?
      @current_company ||= Company.find(session[:current_company_id])
    end
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
