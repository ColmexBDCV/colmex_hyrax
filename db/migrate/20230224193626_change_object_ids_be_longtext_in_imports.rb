class ChangeObjectIdsBeLongtextInImports < ActiveRecord::Migration[5.2]
  def change
    change_column :imports, :object_ids, :text, :limit => 4294967295
  end
end
