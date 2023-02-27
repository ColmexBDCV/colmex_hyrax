class ChangeObjectIdsToLongtextInImports < ActiveRecord::Migration[5.2]
    change_column :imports, :object_ids, :longtext
  def change
  end
end
