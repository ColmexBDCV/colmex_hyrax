class ChangeChangesLogToLongtextInUpdates < ActiveRecord::Migration[5.2]
  def up
    # Ajusta según el adaptador: MySQL necesita LONGTEXT, Postgres y SQLite usan :text
    adapter = ActiveRecord::Base.connection.adapter_name.downcase
    if adapter.include?('mysql')
      execute "ALTER TABLE updates MODIFY changes_log LONGTEXT"
    else
      # Para PostgreSQL y SQLite, :text ya acepta valores grandes; use change_column para portabilidad
      change_column :updates, :changes_log, :text
    end
  end

  def down
    adapter = ActiveRecord::Base.connection.adapter_name.downcase
    if adapter.include?('mysql')
      execute "ALTER TABLE updates MODIFY changes_log TEXT"
    else
      # Dejar como :text por seguridad; si necesitas un tipo más pequeño, ajusta aquí.
      change_column :updates, :changes_log, :text
    end
  end
end
