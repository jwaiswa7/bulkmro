class Suppliers::SessionsController < Devise::SessionsController
  layout 'shared/layouts/sign_in'

  def edit_current_company
    current_suppliers_contact
  end

  def set_current_company
    current_suppliers_contact
  end

  def destroy
    signed_out = sign_out(resource_name)
    session.delete(:current_supplier_company_id) if signed_out
    set_flash_message! :notice, :signed_out if signed_out
    yield if block_given?
    respond_to_on_destroy
  end

  private
    def after_sign_in_path_for(resource_or_scope)
      suppliers_dashboard_path
    end

    def after_sign_out_path_for(resource_or_scope)
      new_suppliers_contact_session_path
    end
end
