class ChangeObjectIdsToLongtextForImports < ActiveRecord::Migration[5.2]
  def change
    change_column :imports, :object_ids, :longtext
  end
end
