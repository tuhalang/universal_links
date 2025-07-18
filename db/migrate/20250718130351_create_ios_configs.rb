class CreateIosConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :ios_configs do |t|
      t.references :dynamic_link, null: false, foreign_key: true
      t.string :app_store_id
      t.string :bundle_identifier
      t.string :custom_scheme
      t.string :universal_link_domain
      t.string :app_store_url
      t.string :fallback_url

      t.timestamps
    end
  end
end
