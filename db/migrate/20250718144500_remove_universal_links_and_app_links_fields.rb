class RemoveUniversalLinksAndAppLinksFields < ActiveRecord::Migration[8.0]
  def change
    # Remove Universal Links fields from ios_configs
    remove_column :ios_configs, :universal_link_domain, :string
    remove_column :ios_configs, :team_id, :string
    remove_column :ios_configs, :app_name, :string

    # Remove App Links fields from android_configs
    remove_column :android_configs, :intent_filter_domain, :string
    remove_column :android_configs, :app_name, :string
    remove_column :android_configs, :cert_sha256_fingerprint, :string
  end
end
