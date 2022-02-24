desc "Copy the entire production database (schema and data) and then run any pending migrations"
task :copy_production_database, [:fast, :args_opts] => :environment do |_task, args|
  raise 'The PRODUCTION_DATABASE_URL environment variable must be set' if ENV['PRODUCTION_DATABASE_URL'].blank?
  raise 'The DATABASE_URL environment variable must be set'            if ENV['DATABASE_URL'].blank?

  raise 'You may not copy a database to itself' if ENV['DATABASE_URL'].strip == ENV['PRODUCTION_DATABASE_URL'].strip

  already_in_progress = true  # until we see otherwise
  LockManager.with_lock(ApplicationController::DATABASE_COPY_ADVISORY_LOCK_NUMBER) do
    already_in_progress = false

    CopyProductionDatabase.copy_most_tables(args[:args_opts], 'document_user_states')

    unless args.key?(:fast)
      CopyProductionDatabase.copy_dus_table
    end

    puts 'Done loading production database content'
    sleep 1
    Rake::Task["db:migrate"].invoke
  end
  raise 'Another copy operation is already in progress' if already_in_progress
end

# Cribbed from http://shiroyasha.io/advisory-locks-and-how-to-use-them.html
module LockManager
  def self.with_lock(number)
    lock = conn.select_value("select pg_try_advisory_lock(#{number});")
    return unless lock
    begin
      yield
    ensure
      conn.execute "select pg_advisory_unlock(#{number});"
    end
  end
  def self.conn
    ActiveRecord::Base.connection
  end
end

module CopyProductionDatabase
  DUS_DATA_DURATION = 2.weeks

  def self.copy_most_tables(args_opts, *excluded_tables)
    puts "Copying most of the table data. Everything but the big table(s)..."

    exclusions   = excluded_tables.map { |table_name| "--exclude-table=#{table_name}" }.join(' ')
    sourcing_cmd = "pg_dump --clean --no-owner --no-privileges #{exclusions} #{args_opts} #{ENV['PRODUCTION_DATABASE_URL']}"
    sinking_cmd  = "psql #{ENV['DATABASE_URL']}"
    system("#{sourcing_cmd} | #{sinking_cmd}")

    puts "Done copying most of the table data"
  end

  def self.copy_dus_table
    duration_str = DUS_DATA_DURATION.parts.map { |key, value| "#{value} #{key.to_s.singularize.pluralize(value)}" }.join(', ')
    puts "Copying #{duration_str} of DocumentUserState data..."

    sink_column_order_sql = <<~EOSQL
      SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_NAME = '#{DocumentUserState.table_name}';
    EOSQL
    column_order_result = `psql -c \"#{sink_column_order_sql}\" #{ENV['DATABASE_URL']}`
    column_order = column_order_result.split("\n")[2..-2].map(&:strip)

    age_condition = DocumentUserState.arel_table[:updated_at].gt(DUS_DATA_DURATION.ago)
    source_sql    = DocumentUserState.where(age_condition).select(column_order).to_sql
    sink_sql      = DocumentUserState.table_name

    sourcing_cmd = "psql -c \"COPY (#{source_sql}) TO STDOUT WITH BINARY;\" #{ENV['PRODUCTION_DATABASE_URL']}"
    sinking_cmd  = "psql -c \"COPY #{sink_sql}   FROM STDIN  WITH BINARY;\" #{ENV['DATABASE_URL']}"
    system("#{sourcing_cmd} | #{sinking_cmd}")

    puts "Done copying DocumentUserState data"
  end
end