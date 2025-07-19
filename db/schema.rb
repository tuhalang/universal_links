# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_19_141852) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "android_configs", force: :cascade do |t|
    t.bigint "dynamic_link_id", null: false
    t.string "package_name"
    t.string "play_store_url"
    t.string "custom_scheme"
    t.string "fallback_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dynamic_link_id"], name: "index_android_configs_on_dynamic_link_id"
  end

  create_table "clicks", force: :cascade do |t|
    t.bigint "dynamic_link_id", null: false
    t.text "user_agent"
    t.string "ip_address"
    t.string "referer"
    t.string "device_type"
    t.string "os_name"
    t.string "os_version"
    t.string "browser_name"
    t.string "browser_version"
    t.string "country"
    t.datetime "clicked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dynamic_link_id"], name: "index_clicks_on_dynamic_link_id"
  end

  create_table "dynamic_links", force: :cascade do |t|
    t.string "title"
    t.string "short_code"
    t.text "description"
    t.string "target_url"
    t.string "social_title"
    t.text "social_description"
    t.string "social_image_url"
    t.boolean "active"
    t.boolean "analytics_enabled"
    t.string "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "auto_params"
    t.boolean "enable_utm_tracking"
    t.boolean "enable_device_params"
    t.bigint "user_id"
    t.index ["short_code"], name: "index_dynamic_links_on_short_code", unique: true
    t.index ["user_id"], name: "index_dynamic_links_on_user_id"
  end

  create_table "ios_configs", force: :cascade do |t|
    t.bigint "dynamic_link_id", null: false
    t.string "app_store_id"
    t.string "bundle_identifier"
    t.string "custom_scheme"
    t.string "app_store_url"
    t.string "fallback_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dynamic_link_id"], name: "index_ios_configs_on_dynamic_link_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "web_configs", force: :cascade do |t|
    t.bigint "dynamic_link_id", null: false
    t.string "desktop_url"
    t.string "fallback_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dynamic_link_id"], name: "index_web_configs_on_dynamic_link_id"
  end

  add_foreign_key "android_configs", "dynamic_links"
  add_foreign_key "clicks", "dynamic_links"
  add_foreign_key "dynamic_links", "users"
  add_foreign_key "ios_configs", "dynamic_links"
  add_foreign_key "web_configs", "dynamic_links"
end
