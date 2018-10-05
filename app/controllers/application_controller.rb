class ApplicationController < ActionController::Base
  before_action :set_raven_context

  def set_flash(object, action, sentiment: :info, now: false)
    flash_hash = now ? flash.now : flash
    flash_hash[sentiment] = flash_message(object, action)
  end

  def set_flash_message(message, sentiment, now: false)
    flash_hash = now ? flash.now : flash
    flash_hash[sentiment] = message
  end

  def flash_message(object, action)
    class_name = object.class.name

    case action.to_sym
    when :create
      "#{class_name} has been successfully created."
    when :update
      "#{class_name} has been successfully updated."
    when :destroy
      "#{class_name} has been successfully destroyed."
    else
      "#{class_name} has been successfully changed."
    end
  end

  def set_raven_context
    if current_overseer.present?
      Raven.user_context(
          # User's ID
          id: current_overseer.id,

          # User's Email address
          email: current_overseer.email,

          # User's IP address
          ip_address: request.ip # '127.0.0.1'
      )
    else
      Raven.user_context(
          # User's IP address
          ip_address: request.ip # '127.0.0.1'
      )
    end

    # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end