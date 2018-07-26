class Overseers::SessionsController < Devise::SessionsController
  layout 'overseers/layouts/sign_in'

  private
  def after_sign_out_path_for(resource_or_scope)
    new_overseer_session_path
  end
end