class DeliveryChallanRow < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasConvertedCalculations
  belongs_to :delivery_challan
  belongs_to :inquiry_product, required: false
  belongs_to :product
  belongs_to :sales_order_row, required: false
  belongs_to :inward_dispatch_row, required: false
  delegate :sales_quote_row, to: :sales_order_row, allow_nil: true
  
  validates_numericality_of :quantity, greater_than: 0, allow_nil: true

  def total_selling_price
    sales_quote_row.unit_selling_price * self.quantity if sales_quote_row.present? && sales_quote_row.unit_selling_price.present?
  end

  def converted_unit_selling_price
    sales_quote_row.present? && sales_quote_row.conversion_rate.present? ? (sales_quote_row.unit_selling_price / self.sales_quote_row.conversion_rate) : self&.sales_quote_row&.unit_selling_price
  end

  def converted_total_selling_price
    sales_quote_row.present? && sales_quote_row.conversion_rate.present? ? (self.total_selling_price / sales_quote_row.conversion_rate) : self.total_selling_price
  end

  def unit_selling_price_with_tax
    sales_quote_row.unit_selling_price + (sales_quote_row.unit_selling_price * sales_quote_row.applicable_tax_percentage) if sales_quote_row.present?
  end

  def total_selling_price_with_tax
    self.quantity ? self.unit_selling_price_with_tax * self.quantity : 0
  end

  def converted_total_selling_price_with_tax
    sales_quote_row.present? && sales_quote_row.conversion_rate.present? ? (self.total_selling_price_with_tax / sales_quote_row.conversion_rate) : self.total_selling_price_with_tax
  end

  def total_tax
    total_selling_price_with_tax - total_selling_price
  end

  def converted_total_tax
    converted_total_selling_price_with_tax - converted_total_selling_price
  end

  def get_quantity
    if self.delivery_challan.purpose == 'Regular Flow'
      get_quantity_for_regular_flow
    else
      get_quantity_for_sample_flow
    end
  end

  def get_quantity_for_sample_flow(action=nil)
    created_from = case self.delivery_challan.created_from
    when 'Inquiry'
      ['inquiry_product_id', self.inquiry_product_id]
    when 'DeliveryChallan'
      if self.sales_order_row.present?
        ['sales_order_row_id', self.sales_order_row_id]
      else
        ['inquiry_product_id', self.inquiry_product_id]
      end
    end

    used_quantity = if action.present?
      DeliveryChallanRow.where("#{created_from[0]} = ?", created_from[1]).where.not(id: self.id).sum(&:quantity)
    else
      DeliveryChallanRow.where("#{created_from[0]} = ?", created_from[1]).sum(&:quantity)
    end
    
    if used_quantity < self.total_quantity
      self.total_quantity - used_quantity
    else
      0
    end
  end

  def get_quantity_for_regular_flow(action=nil)
    created_from = case self.delivery_challan.created_from
    when 'InwardDispatch'
      ['inward_dispatch_row_id', self.inward_dispatch_row_id]
    when 'SalesOrder', 'DeliveryChallan'
      ['sales_order_row_id', self.sales_order_row_id]
    end

    used_quantity = if action.present?
      DeliveryChallanRow.where("#{created_from[0]} = ?", created_from[1]).where.not(id: self.id).sum(&:quantity)
    else
      DeliveryChallanRow.where("#{created_from[0]} = ?", created_from[1]).sum(&:quantity)
    end
    
    if used_quantity < self.total_quantity
      self.total_quantity - used_quantity
    else
      0
    end
  end

end