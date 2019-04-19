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
            @messages.push("For product #{product}, #{field.titleize} changed from #{record.send("#{field}_was")} to #{record.send("#{field}")}")
          else
            @messages.push("For product #{product}, #{field.titleize} Set to #{record.send("#{field}")}")
          end
        else
          if record.send("#{field}_was").present?
            @messages.push("#{field.titleize} Changed from #{record.send("#{field}_was")} to #{record.send("#{field}")}")
          else
            @messages.push("#{field.titleize} Set to #{record.send("#{field}")}")
          end
        end
      end

      def for_associations(record, field)
        model = (field == 'logistics_owner_id') ? 'Overseer' : field.split('_id')[0].camelcase

        field_is = model.constantize.find(record.send("#{field}")).to_s
        if record.send("#{field}_was").present?
          field_was = model.constantize.find(record.send("#{field}_was")).to_s
          @messages.push("#{field.titleize} Changed from #{field_was} to #{field_is}")
        else
          @messages.push("#{field.titleize} Set to #{field_is}")
        end
      end

      def for_date_fields(record, field, product)
        if product.present?
          if record.send("#{field}_was").present?
            @messages.push("For product #{product}, #{field.titleize} changed from #{record.send("#{field}_was")} to #{record.send("#{field}")}")
          else
            @messages.push("For product #{product}, #{field.titleize} Set to #{record.send("#{field}")}")
          end
        else
          if record.send("#{field}_was").present?
            @messages.push("#{field.titleize} Changed from #{record.send("#{field}_was").try(:strftime, "%d-%b-%Y")} to #{record.send("#{field}").try(:strftime, "%d-%b-%Y")}")
          else
            @messages.push("#{field.titleize} Set to #{record.send("#{field}").try(:strftime, "%d-%b-%Y")}")
          end
        end
      end
  end
end
