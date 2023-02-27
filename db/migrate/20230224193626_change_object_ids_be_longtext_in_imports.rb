class ChangeObjectIdsBeLongtextInImports < ActiveRecord::Migration
  def change
    change_column :imports, :object_ids, :text, :limit => 4294967295
  end
end
