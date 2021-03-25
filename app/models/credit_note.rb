class CreditNote < ApplicationRecord
  include Mixins::CanBeSynced
  update_index('credit_notes#credit_note') { self }

  belongs_to :sales_invoice
  scope :with_includes, -> { includes(:sales_invoice) }

  def matched_rows
    sales_invoice.rows.select { |row| metadata['lineItems'].pluck('sku').include?(row.sku) }
  end

  def filename(include_extension: false)
    [
        ['invoice', memo_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def matched_row_total_tax
    matched_rows.map { |row| (row.metadata['base_tax_amount'].to_f * row.sales_invoice.metadata['base_to_order_rate'].to_f) }.sum.round(2)
  end
end
