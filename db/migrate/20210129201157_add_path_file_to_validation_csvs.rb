class AddPathFileToValidationCsvs < ActiveRecord::Migration[5.1]
  def change
    add_column :validation_csvs, :path_file_csv, :string
  end
end
