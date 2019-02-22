class ApplicationController < ActionController::Base
  before_action :set_raven_context, if: :production?
  before_action :set_raven_context, if: :staging?

  def render_pdf_for(record)
    render(
      pdf: record.filename,
      template: ['shared', 'layouts', 'pdf_templates', record.class.name.pluralize.underscore, 'show'].join('/'),
      layout: 'shared/layouts/pdf_templates/show',
      page_size: 'A4',
      footer: {
          center: '[page] of [topage]'
      },
      locals: {
          record: record
      }
    )
  end




  private
    def production?
      Rails.env.production?
    end

    def staging?
      Rails.env.staging?
    end

    def set_flash(object, action, sentiment: :info, now: false)
      flash_hash = now ? flash.now : flash
      flash_hash[sentiment] = flash_message(object, action)
    end

    def set_flash_message(message, sentiment, now: false)
      flash_hash = now ? flash.now : flash
      flash_hash[sentiment] = message
    end

    def flash_message(object, action)
      class_name = object.class.name.titleize

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
          id: current_overseer.id,
          email: current_overseer.email,
          ip_address: request.ip

        )
      else
        Raven.user_context(
          ip_address: request.ip
        )
      end

      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end
end
