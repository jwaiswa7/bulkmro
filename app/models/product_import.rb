class ProductImport < ApplicationRecord
  belongs_to :overseer

  include Mixins::IsAnImport

  has_many :email_messages, as: :emailable


  TEMPLATE_HEADERS = %w[sr_no name measurement_unit brand mpn tax_code tax_rate is_service category_id]
end
