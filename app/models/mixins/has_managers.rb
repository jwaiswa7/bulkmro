module Mixins::HasManagers
  extend ActiveSupport::Concern

  included do
    belongs_to :inside_sales_owner, -> { sales }, class_name: 'Overseer', foreign_key: 'inside_sales_owner_id'
    belongs_to :outside_sales_owner, -> { sales }, class_name: 'Overseer', foreign_key: 'outside_sales_owner_id', required: false
    belongs_to :sales_manager, -> { sales_manager }, class_name: 'Overseer', foreign_key: 'sales_manager_id', required: false

    after_initialize :set_insider_sales_owner, if: :new_record_and_overseer_defined?
    def set_insider_sales_owner
      self.insider_sales_owner ||= overseer
    end
  end
end