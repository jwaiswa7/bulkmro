

class Overseers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @overseer = Overseer.from_omniauth(request.env['omniauth.auth'])

    if @overseer.present? && @overseer.persisted?
      # @overseer.update_attributes(:role => :admin)
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @overseer, event: :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_overseer_session_url
    end
  end

  def failure
    redirect_to new_overseer_session_url
  end
end
