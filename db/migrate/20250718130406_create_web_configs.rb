class CreateWebConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :web_configs do |t|
      t.references :dynamic_link, null: false, foreign_key: true
      t.string :desktop_url
      t.string :fallback_url

      t.timestamps
    end
  end
end
