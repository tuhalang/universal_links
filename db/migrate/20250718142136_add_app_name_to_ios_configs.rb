class AddAppNameToIosConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :ios_configs, :app_name, :string
  end
end
