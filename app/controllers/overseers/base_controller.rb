class Overseers::BaseController < ApplicationController
  include Pundit
  # include Acl
  #
  helper_method :get_acl_resource_json, :authorized

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # rescue_from NotAuthorised, with: :user_not_authorized
  layout 'overseers/layouts/application'

  before_action :authenticate_overseer!
  before_action :set_paper_trail_whodunnit

  def authorize_acl(model, action = nil)
    action = action_name if action.blank?
    if current_overseer.present?
      @authorized = false
      if current_overseer.is_super_admin
        @authorized = true
      else
        allowed_resources = ActiveSupport::JSON.decode(current_overseer.acl_resources)
        resource_ids = get_acl_resource_ids

        if model.is_a?(ActiveRecord::Base)
          resource_model = model.class.name.underscore.downcase
        elsif model.is_a?(ActiveRecord::Relation)
          resource_model = model.klass.name.underscore.downcase
        else
          resource_model = model.to_s.gsub(':', '')
        end
        if resource_ids[resource_model].blank? && resource_ids[resource_model][action].blank?
          @authorized = false
        elsif allowed_resources.include? resource_ids[resource_model][action].to_s
          @authorized = true
        end
      end
      if @authorized == false
        message = 'You are not authorized to perform this action.'
        set_flash_message(message, :warning, now: false)
        redirect_to(request.referrer || root_path)
      end
    end
  end

  def get_acl_resource_json
    Rails.cache.fetch('acl_resource_json', expires_in: 3.hours) do
      AclResource.acl_resource_json
    end
  end

  def get_acl_menu_resource_json
    Rails.cache.fetch('acl_menu_resource_json', expires_in: 3.hours) do
      AclResource.acl_menu_resource_json
    end
  end

  def get_acl_resource_ids
    Rails.cache.fetch('acl_resource_ids', expires_in: 3.hours) do
      AclResource.acl_resource_ids
    end
  end

  private

  def render_pdf_for(record, locals = {})
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
        }.merge(locals)
    )
  end

  #Not used anymore
  def user_not_authorized
    message = 'You are not authorized to perform this action.'
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

  def pundit_user
    current_overseer
  end

  def stamping_user
    current_overseer
  end

  def namespace
    controller_namespace.capitalize
  end

  def user_for_paper_trail
    current_overseer.to_gid.to_s if current_overseer.present?
  end

  def controller_namespace
    @controller_namespace ||= controller_path.split('/').first
  end

  def controller_action_name
    @controller_action_name ||= controller_path.split('/').last
  end

  def set_notification
    @notification = Services::Overseers::Notifications::Notify.new(current_overseer, self.namespace)
  end

end
