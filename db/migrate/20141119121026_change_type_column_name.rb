class ChangeTypeColumnName < ActiveRecord::Migration
  def self.up
    rename_column :messages, :type, :message_type
  end
  def self.down
    # rename back if you need or do something else or do nothing
  end
end
