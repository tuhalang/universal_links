class CreateAndroidConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :android_configs do |t|
      t.references :dynamic_link, null: false, foreign_key: true
      t.string :package_name
      t.string :play_store_url
      t.string :custom_scheme
      t.string :intent_filter_domain
      t.string :fallback_url

      t.timestamps
    end
  end
end
