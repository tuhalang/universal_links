class AddTeamIdToIosConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :ios_configs, :team_id, :string
  end
end
