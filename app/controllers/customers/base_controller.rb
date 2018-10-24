class Customers::BaseController < ApplicationController
  include Pundit
  layout 'customers/layouts/application'

  before_action :authenticate_contact!
  before_action :set_paper_trail_whodunnit

  helper_method :current_cart

  def current_cart
    debugger
    if session[:cart_id]
      Cart.find(session[:cart_id])
    else
      Cart.new
    end
  end

  def current_customer_order
    debugger
    if session[:customer_order_id]
      CustomerOrder.find(session[:customer_order_id])
    end
  end

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
