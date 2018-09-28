require 'csv'

class Services::Shared::Spreadsheets::CsvImporter < Services::Shared::BaseService
  def initialize(name)
    set_file(name)
    # set_rows_count
  end

  def loop(limit=nil)
    CSV.foreach(file, :headers => true) do |row|
      set_current_row(row.to_h)
      yield self
      break if limit.present? && $..to_i > limit
    end
  end

  def set_file(name)
    @file = Rails.root.join('db', 'seed_files', name)
  end

  def set_rows_count
     @rows_count = `wc -l #{file}`.to_i
  end

  def set_current_row(row_hash)
    @current_row = row_hash
  end
  
  def get_column(name)
    current_row[name].strip if current_row[name].present? && current_row[name] != 'NULL'
  end

  def get_underscored(name)
    val = get_column(name)
    val.parameterize.underscore.to_sym if val.present?
  end

  attr_accessor :file, :current_row #, :rows_count
end