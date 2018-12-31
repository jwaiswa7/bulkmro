# https://github.com/delynn/userstamp/blob/master/lib/userstamp/migration_helper.rb

module MigrationHelper
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def userstamps(table=:overseers)
      column(:created_by_id, :integer, index: true)
      column(:updated_by_id, :integer, index: true)

      foreign_key(table, column: 'created_by_id')
      foreign_key(table, column: 'updated_by_id')
    end
  end
end

ActiveRecord::ConnectionAdapters::Table.send(:include, MigrationHelper)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, MigrationHelper)