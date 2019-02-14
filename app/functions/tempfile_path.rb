# frozen_string_literal: true

class TempfilePath < BaseFunction
  def self.for(attachment)
    tempfile = Tempfile.new

    File.open(tempfile, 'wb') do |f|
      f.write(attachment.download)
    end

    tempfile.path
  end
end
