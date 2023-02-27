class ChangeLimitTypeWorkToValidationCsvs < ActiveRecord::Migration
  def change
    change_column :validation_csvs, :type_work, :string, :limit => 100
  end
end
