# frozen_string_literal: true

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

    # def notification_message(type, *args)
    #   case type.to_sym
    #   when :send_inquiry_product
    #     "#{args[0]} uploaded for approval in Inquiry ##{args[1]}"
    #   when :inquiry_product_comment
    #     if args[0].present?
    #       "Product #{args[1]} has been #{args[0]}"
    #     else
    #       msg = "New reply for Product #{args[1]}"
    #       msg = "#{msg.to_s}: #{args[2]}" if args[2].present?
    #     end
    #   when :inquiry_order_comment
    #     if args[0].present?
    #       "Order for Inquiry ##{args[1]} has been #{args[0]}"
    #     else
    #       msg = "New reply for order of Inquiry #{args[1]}"
    #       msg = "#{msg.to_s}: #{args[2]}" if args[2].present?
    #     end
    #   when :order_init
    #     "New Order for inquiry ##{args[0]} awaiting approval"
    #   else
    #     "You have new notification"
    #   end
    # end

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
