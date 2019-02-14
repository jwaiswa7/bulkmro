

require 'csv'

class Services::Shared::Spreadsheets::CsvImporter < Services::Shared::BaseService
  def initialize(name, folder, skip = 0, log_errors = false)
    @errors = []
    @skip = skip
    @log_errors = log_errors

    set_files(name, folder)
  end

  def loop(limit = nil)
    CSV.foreach(file, headers: true) do |row|
      next if skip.present? && $..to_i <= skip

      set_current_row(row.to_h)

      # begin
      yield self
      # rescue => error
      # errors.push("#{error.inspect} - #{row.to_h}")
      # end

      break if limit.present? && $..to_i > limit
    end

    errors_to_csv if log_errors

    file
  end

  def set_files(name, folder)
    folder = 'seed_files' if !folder.present?
    @file = Rails.root.join('db', folder, name)
    @errors_file = Rails.root.join('db', 'seed_errors_files', name)
  end

  def set_current_row(row_hash)
    @current_row = row_hash
  end

  def get_column(name, nil_if_zero: false, default: nil, downcase: false, to_datetime: false, remove_whitespace: false, to_f: false)
    value = if current_row[name].present? && current_row[name] != 'NULL'
      if nil_if_zero
        current_row[name].to_s == '0' ? nil : current_row[name].strip
      else
        current_row[name].strip
      end
    else
      default
    end

    if value.present?
      value = value.gsub(/\s+/, '') if remove_whitespace
      value = value.downcase if downcase
      value = (value == '0000-00-00' ? Time.at(0) : value.to_datetime) if to_datetime
      value = value.to_f if to_f
      value
    else
      value
    end
  end

  def get_row
    current_row
  end

  def get_underscored(name)
    val = get_column(name)
    val.parameterize.underscore.to_sym if val.present?
  end

  def errors_to_csv
    CSV.open(errors_file, 'w', write_headers: true, headers: ['Errors']) do |f|
      f << errors
    end
  end

  attr_accessor :skip, :file, :errors_file, :errors, :current_row, :log_errors
end
