class SalesOrder < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_approval
end
