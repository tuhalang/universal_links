class AddAppNameAndCertFingerprintToAndroidConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :android_configs, :app_name, :string
    add_column :android_configs, :cert_sha256_fingerprint, :string
  end
end
