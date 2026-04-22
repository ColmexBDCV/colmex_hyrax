class AddChangesLogToUpdates < ActiveRecord::Migration[5.2]
  def change
    add_column :updates, :changes_log, :text unless column_exists?(:updates, :changes_log)
  end
end
