class AddRepnalToImports < ActiveRecord::Migration[5.2]
  def change
    add_column :imports, :repnal, :string
  end
end
