class CreateImports < ActiveRecord::Migration[5.2]
  def change
    create_table :imports do |t|
      t.string :name
      t.string :object_type
      t.string :depositor
      t.datetime :date
      t.string :storage_size
      t.string :status
      t.text :object_ids
      t.integer :num_records

      t.timestamps
    end
  end
end
