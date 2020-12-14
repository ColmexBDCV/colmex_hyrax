class CreateValidationCsvs < ActiveRecord::Migration[5.2]
  def change
    create_table :validation_csvs do |t|
      t.string :user, limit: 50
      t.string :original_name
      t.string :new_name, limit: 60
      t.string :type_work, limit: 20

      t.timestamps
    end
  end
end
