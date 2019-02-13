class DeviseCreateOverseers < ActiveRecord::Migration[5.2]
  def change
    create_table :overseers do |t|
      t.integer :parent_id, index: true
      t.integer :legacy_id, index: true
      t.string :slack_uid
      t.integer :salesperson_uid, index: { :unique => true }
      t.integer :employee_uid, index: { :unique => true }
      t.integer :center_code_uid, index: { :unique => true }

      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :mobile
      t.string :telephone
      t.string :designation
      t.string :identifier
      t.string :department
      t.string :function
      t.string :geography

      t.integer :status, index: true

      t.integer :role, index: true

      t.string :google_oauth2_uid
      t.jsonb :google_oauth2_metadata
      t.jsonb :legacy_metadata

      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :smtp_password

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at


      t.timestamps null: false
      t.userstamps
    end

    # add_index :overseers, :confirmation_token,   unique: true
    add_index :overseers, :email,                unique: true
    add_index :overseers, :reset_password_token, unique: true
    add_index :overseers, :unlock_token,         unique: true
    add_foreign_key :overseers, :overseers, column: :parent_id
  end
end
