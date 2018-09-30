require 'csv'

class Services::Shared::Spreadsheets::CsvImporter < Services::Shared::BaseService
  def initialize(name, log_errors = true)
    @errors = []
    @log_errors = log_errors

    set_files(name)
  end

  def loop(limit = nil)
    CSV.foreach(file, :headers => true) do |row|
      set_current_row(row.to_h)
      begin
        yield self
      rescue => error
        errors.push("#{error.inspect} - #{row.to_h}")
      end

      break if limit.present? && $..to_i > limit
    end

    errors_to_csv if log_errors
  end

  def set_files(name)
    @file = Rails.root.join('db', 'seed_files', name)
    @errors_file = Rails.root.join('db', 'seed_errors_files', name)
  end

  def set_current_row(row_hash)
    @current_row = row_hash
  end

  def get_column(name, nil_if_zero: false, default: nil, downcase: false)
    value = if current_row[name].present? && current_row[name] != 'NULL'
              if nil_if_zero
                current_row[name].to_s == '0' ? nil : current_row[name].strip
              else
                current_row[name].strip
              end
            else
              default
            end

    if value.present? && downcase
      value.downcase
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
    CSV.open(errors_file, 'w', write_headers: true, headers: ['Error']) do |f|
      f << error
    end
  end

  attr_accessor :file, :errors_file, :errors, :current_row, :log_errors
end