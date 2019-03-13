class FieldModifiedMessage < BaseFunction
  class << self
    def for(record, fields = '')
      @messages = []
      fields.each do |field|
        if record.send("#{field}_changed?")
          # raise
          if field.match?(/date/i)
            for_date_fields(record, field)
          else
            for_text_fields(record, field)
          end
        end
      end
      # add id

      @messages.join(" \r\n")
    end

    private

      def for_text_fields(record, field)
        if record.send("#{field}_was").present?
          @messages.push("#{field.titleize} Changed from #{record.send("#{field}_was")} to #{record.send("#{field}")}")
        else
          @messages.push("#{field.titleize} Set to #{record.send("#{field}")}")
        end
      end

      def for_date_fields(record, field)
        if record.send("#{field}_was").present?
          @messages.push("#{field.titleize} Changed from #{record.send("#{field}_was").try(:strftime, "%d-%b-%Y")} to #{record.send("#{field}").try(:strftime, "%d-%b-%Y")}")
        else
          @messages.push("#{field.titleize} Set to #{record.send("#{field}").try(:strftime, "%d-%b-%Y")}")
        end
      end
  end
end
