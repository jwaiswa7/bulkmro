class FieldModifiedMessage < BaseFunction
  class << self
    def for(record, fields = '', product = '')
      @messages = []
      fields.each do |field|
        if record.send("#{field}_changed?")
          if field.match?(/date/i) && field != "late_lead_date_reason"
            for_date_fields(record, field, product)
          elsif field.match?(/id/i)
            for_associations(record, field)
          else
            for_text_fields(record, field, product)
          end
        end
      end

      @messages.join(" \r\n")
    end

    private

    def for_text_fields(record, field, product)
      if product.present?
        if record.send("#{field}_was").present?
          @messages.push("<b> For product #{product}, #{field.titleize} changed from </b> #{record.send("#{field}_was")} <b> to </b> #{record.send("#{field}")}".html_safe)
        else
          @messages.push("<b> For product #{product}, #{field.titleize} Set to </b> #{record.send("#{field}")}".html_safe)
        end
      else
        if record.send("#{field}_was").present?
          @messages.push("<b> #{field.titleize} Changed from </b> #{record.send("#{field}_was")} <b> to </b> #{record.send("#{field}")}".html_safe)
        else
          @messages.push("<b> #{field.titleize} Set to </b> #{record.send("#{field}")}".html_safe)
        end
      end
    end

    def for_associations(record, field)
      model = case field
      when 'logistics_owner_id'
        'Overseer'
      when 'bill_from_id', 'ship_from_id', 'bill_to_id', 'ship_to_id', 'supplier_bill_from_id', 'supplier_ship_from_id', 'customer_bill_from_id', 'customer_ship_from_id'
        'Address'
      else
        field.split('_id')[0].camelcase
      end

      field_is = model.constantize.find(record.send("#{field}")).to_s
      if record.send("#{field}_was").present?
        field_was = model.constantize.find(record.send("#{field}_was")).to_s
        @messages.push("<b> #{field.titleize} Changed from </b> #{field_was} <b> to </b> #{field_is}".html_safe)
      else
        @messages.push("<b> #{field.titleize} Set to </b> #{field_is}".html_safe)
      end
    end

    def for_date_fields(record, field, product)
      if product.present?
        if record.send("#{field}_was").present?
          @messages.push("<b> For product #{product}, #{field.titleize} changed from </b> #{record.send("#{field}_was")} <b> to </b> #{record.send("#{field}")}".html_safe)
        else
          @messages.push("<b> For product #{product}, #{field.titleize} Set to </b> #{record.send("#{field}")}".html_safe)
        end
      else
        if record.send("#{field}_was").present?
          @messages.push("<b> #{field.titleize} Changed from </b> #{record.send("#{field}_was").try(:strftime, "%d-%b-%Y")} <b> to </b> #{record.send("#{field}").try(:strftime, "%d-%b-%Y")}".html_safe)
        else
          @messages.push("<b> #{field.titleize} Set to </b> #{record.send("#{field}").try(:strftime, "%d-%b-%Y")}".html_safe)
        end
      end
    end
  end
end
