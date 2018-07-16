class Overseers::BaseController < ApplicationController
	include Pundit
	layout 'overseers/layouts/application'

	# before_action :authenticate_overseer!
	# before_action :set_paper_trail_whodunnit
	# after_action :verify_authorized

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
		Overseer.new
	end

	def namespace
		controller_namespace.capitalize
	end

	def user_for_paper_trail
		current_overseer.to_gid.to_s
	end

	def controller_namespace
		@controller_namespace ||= controller_path.split('/').first
	end

	def set_flash(object, action, sentiment: :info, now: false)
		flash_hash = now ? flash.now : flash
		class_name = object.class.name

		case action.to_sym
			when :create
				flash_hash[sentiment] = "#{class_name} has been successfully created."
			when :update
				flash_hash[sentiment] = "#{class_name} has been successfully updated."
			when :destroy
				flash_hash[sentiment] = "#{class_name} has been successfully destroyed."
			else
				flash_hash[sentiment] = "#{class_name} has been successfully changed."
		end
	end
end
