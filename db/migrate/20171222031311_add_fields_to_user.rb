class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :firstname, :string
    add_column :users, :paternal_surname, :string
    add_column :users, :maternal_surname, :string
    add_column :users, :phone, :string
  end
end
