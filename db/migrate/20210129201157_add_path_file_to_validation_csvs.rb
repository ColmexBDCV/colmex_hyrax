class AddPathFileToValidationCsvs < ActiveRecord::Migration
  def change
    add_column :validation_csvs, :path_file_csv, :string
  end
end
