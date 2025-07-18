class CreateClicks < ActiveRecord::Migration[8.0]
  def change
    create_table :clicks do |t|
      t.references :dynamic_link, null: false, foreign_key: true
      t.text :user_agent
      t.string :ip_address
      t.string :referer
      t.string :device_type
      t.string :os_name
      t.string :os_version
      t.string :browser_name
      t.string :browser_version
      t.string :country
      t.datetime :clicked_at

      t.timestamps
    end
  end
end
