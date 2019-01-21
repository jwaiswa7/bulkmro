class DateModifiedMessage < BaseFunction
  def self.for(record, fields = '')
    messages = []
    if fields.is_a?(Array)
      fields.each do |field|
        if record.send("#{field}_changed?")
          messages.push("#{field.titleize} Changed from #{record.send("#{field}_was").try(:strftime, "%d-%b-%Y")} to #{record.send("#{field}").try(:strftime, "%d-%b-%Y")}")
        end
      end
    else
      if record.send("#{fields}_changed?")
        messages.push("#{fields.titleize} Changed from #{record.send("#{fields}_was").try(:strftime, "%d-%b-%Y")} to #{record.send("#{fields}").try(:strftime, "%d-%b-%Y")}")
      end
    end

    return messages.join(" \r\n")
  end
end