class AddParameterSettingsToDynamicLinks < ActiveRecord::Migration[8.0]
  def change
    add_column :dynamic_links, :auto_params, :text
    add_column :dynamic_links, :enable_utm_tracking, :boolean
    add_column :dynamic_links, :enable_device_params, :boolean
  end
end
