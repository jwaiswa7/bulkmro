class CreditNote < ApplicationRecord
  include Mixins::CanBeSynced
  update_index('credit_notes') { self }

  belongs_to :sales_invoice, required: false
  scope :with_includes, -> { includes(:sales_invoice) }

  validates_presence_of :memo_number
  validates_uniqueness_of :memo_number

  def matched_rows
    sales_invoice&.rows&.select { |row| metadata['lineItems'].pluck('sku').include?(row.sku) }
  end

  def filename(include_extension: false)
    [
        ['invoice', memo_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def matched_row_total_tax
    matched_rows&.map { |row| (row.metadata['base_tax_amount'].to_f * row.sales_invoice.metadata['base_to_order_rate'].to_f) }&.sum&.round(2)
  end

  def matched_row_total
    matched_rows&.map { |row| (row.metadata['base_row_total'].to_f * row.sales_invoice.metadata['base_to_order_rate'].to_f) }&.sum&.round(2)
  end

  def calculated_total_with_tax
    (matched_row_total.to_f + matched_row_total_tax.to_f).round(2)
  end
end
