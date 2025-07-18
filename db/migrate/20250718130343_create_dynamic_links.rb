class CreateDynamicLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :dynamic_links do |t|
      t.string :title
      t.string :short_code
      t.text :description
      t.string :target_url
      t.string :social_title
      t.text :social_description
      t.string :social_image_url
      t.boolean :active
      t.boolean :analytics_enabled
      t.string :created_by

      t.timestamps
    end
    add_index :dynamic_links, :short_code, unique: true
  end
end
