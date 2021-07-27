class ChangeLimitTypeWorkToValidationCsvs < ActiveRecord::Migration[5.1]
  def change
    change_column :validation_csvs, :type_work, :string, :limit => 100
  end
end
