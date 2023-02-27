class AddRepnalToImports < ActiveRecord::Migration
  def change
    add_column :imports, :repnal, :string
  end
end
