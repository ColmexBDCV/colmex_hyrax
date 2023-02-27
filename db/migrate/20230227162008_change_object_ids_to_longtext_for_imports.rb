class ChangeObjectIdsToLongtextForImports < ActiveRecord::Migration
  def change
    change_column :imports, :object_ids, :longtext
  end
end
