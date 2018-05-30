class AddFieldsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :firstname, :string
    add_column :users, :paternal_surname, :string
    add_column :users, :maternal_surname, :string
    add_column :users, :phone, :string
  end
end
