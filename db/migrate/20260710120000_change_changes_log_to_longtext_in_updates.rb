class ChangeChangesLogToLongtextInUpdates < ActiveRecord::Migration[5.2]
  def up
    # Cambia la columna a LONGTEXT en MySQL para aceptar entradas muy grandes
    execute <<-SQL.squish
      ALTER TABLE updates MODIFY changes_log LONGTEXT
    SQL
  end

  def down
    # Revertir a TEXT (límite ~64KB)
    execute <<-SQL.squish
      ALTER TABLE updates MODIFY changes_log TEXT
    SQL
  end
end
