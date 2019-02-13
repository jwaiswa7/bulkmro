

module Mixins::CanHaveTaxes
  extend ActiveSupport::Concern

  included do
    belongs_to :tax_code, required: false
    belongs_to :tax_rate, required: false

    delegate :tax_percentage, :gst_rate, to: :tax_rate, allow_nil: true
  end
end
