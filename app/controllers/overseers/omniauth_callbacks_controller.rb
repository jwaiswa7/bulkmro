# frozen_string_literal: true

class Overseers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @overseer = Overseer.from_omniauth(request.env['omniauth.auth'])
    if @overseer.present? && @overseer.persisted?
      # @overseer.update_attributes(:role => :admin)
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in @overseer, event: :authentication
      redirect_to after_sign_in_path_for(@overseer)
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_overseer_session_url
    end
  end

  def failure
    redirect_to new_overseer_session_url
  end

  private
  def after_sign_in_path_for(resource)
    if resource.sales? && current_overseer.descendant_ids.present?
      sales_manager_overseers_dashboard_path
    elsif resource.sales? && !current_overseer.descendant_ids.present?
      sales_executive_overseers_dashboard_path
    elsif resource.acl_role.role_name == 'Accounts' || resource.acl_role.role_name == 'Account Manager'
      accounts_overseers_dashboard_path
    else
      overseers_inquiries_path
    end
  end
end
