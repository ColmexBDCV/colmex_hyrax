class CreateRecordChangeLog < ActiveRecord::Migration[5.2]
  def change
    create_table :record_change_logs do |t|
      t.references :user, foreign_key: true
      t.string :template
      t.string :record_id
      t.string :identifier
      t.json :change
     
      t.timestamps
    end
  end
end
