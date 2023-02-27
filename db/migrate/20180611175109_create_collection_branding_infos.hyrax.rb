class CreateCollectionBrandingInfos < ActiveRecord::Migration
  def change
    create_table :collection_branding_infos do |t|
      t.string :collection_id
      t.string :role
      t.string :local_path
      t.string :alt_text
      t.string :target_url
      t.integer :height
      t.integer :width

      t.timestamps
    end
  end
end
