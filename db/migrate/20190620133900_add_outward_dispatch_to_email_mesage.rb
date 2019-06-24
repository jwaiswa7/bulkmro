class AddOutwardDispatchToEmailMesage < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages, :outward_dispatch
  end
end
