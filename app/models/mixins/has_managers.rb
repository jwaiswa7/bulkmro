

module Mixins::HasManagers
  extend ActiveSupport::Concern

  included do
    # belongs_to :inside_sales_owner, ->(record) do
    #   record.legacy? ? order(:first_name) : inside_sales_executive.order(:first_name)
    # end, class_name: 'Overseer', foreign_key: 'inside_sales_owner_id', required: false
    #
    # belongs_to :outside_sales_owner, ->(record) do
    #   record.legacy? ? order(:first_name) : outside_sales_executive.order(:first_name)
    # end, class_name: 'Overseer', foreign_key: 'outside_sales_owner_id', required: false
    #
    # belongs_to :sales_manager, ->(record) do
    #   record.legacy? ? order(:first_name) : sales_manager.order(:first_name)
    # end, class_name: 'Overseer', foreign_key: 'sales_manager_id', required: false

    belongs_to :inside_sales_owner, -> { order(:first_name) }, class_name: "Overseer", foreign_key: "inside_sales_owner_id", required: false
    belongs_to :outside_sales_owner, -> { order(:first_name) }, class_name: "Overseer", foreign_key: "outside_sales_owner_id", required: false
    belongs_to :sales_manager, -> { order(:first_name) }, class_name: "Overseer", foreign_key: "sales_manager_id", required: false

    after_initialize :set_insider_sales_owner, if: :new_record_and_overseer_defined?

    def set_insider_sales_owner
      # self.inside_sales_owner ||= overseer
    end
  end
end
