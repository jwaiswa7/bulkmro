class Overseers::SessionsController < Devise::SessionsController
  layout 'shared/layouts/sign_in'

  private
    def after_sign_in_path_for(resource)
      if resource.sales? && current_overseer.descendant_ids.present?
        sales_manager_overseers_dashboard_path
      elsif resource.sales? && !current_overseer.descendant_ids.present?
        sales_executive_overseers_dashboard_path
      elsif resource.acl_accounts?
        accounts_overseers_dashboard_path
      else
        overseers_inquiries_path
      end
    end
    def after_sign_out_path_for(resource_or_scope)
      new_overseer_session_path
    end
end
