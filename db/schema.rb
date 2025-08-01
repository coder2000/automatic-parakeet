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

ActiveRecord::Schema[8.0].define(version: 2025_07_30_192051) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "download_links", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "url"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_download_links_on_game_id"
  end

  create_table "download_links_platforms", id: false, force: :cascade do |t|
    t.bigint "download_link_id", null: false
    t.bigint "platform_id", null: false
    t.index ["download_link_id", "platform_id"], name: "index_dl_platforms_on_dl_id_and_platform_id", unique: true
    t.index ["download_link_id"], name: "index_download_links_platforms_on_download_link_id"
    t.index ["platform_id"], name: "index_download_links_platforms_on_platform_id"
  end

  create_table "downloads", force: :cascade do |t|
    t.string "ip_address"
    t.integer "count", default: 0
    t.bigint "user_id"
    t.bigint "download_link_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["download_link_id"], name: "index_downloads_on_download_link_id"
    t.index ["user_id"], name: "index_downloads_on_user_id"
  end

  create_table "followings", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_followings_on_game_id"
    t.index ["user_id"], name: "index_followings_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "game_languages", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "language_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "language_code"], name: "index_game_languages_on_game_id_and_language_code", unique: true
    t.index ["game_id"], name: "index_game_languages_on_game_id"
    t.index ["language_code"], name: "index_game_languages_on_language_code"
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description", null: false
    t.integer "release_type", default: 0, null: false
    t.float "rating_avg", default: 0.0, null: false
    t.integer "rating_count", default: 0, null: false
    t.float "rating_abs", default: 0.0, null: false
    t.boolean "adult_content", default: false
    t.bigint "user_id"
    t.bigint "tool_id"
    t.bigint "genre_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "screenshots_count", default: 0, null: false
    t.integer "videos_count", default: 0, null: false
    t.bigint "cover_image_id"
    t.string "author"
    t.boolean "mobile", default: false, null: false
    t.text "long_description"
    t.string "website"
    t.boolean "indiepad", default: false
    t.index ["author"], name: "index_games_on_author"
    t.index ["cover_image_id"], name: "index_games_on_cover_image_id"
    t.index ["genre_id"], name: "index_games_on_genre_id"
    t.index ["screenshots_count"], name: "index_games_on_screenshots_count"
    t.index ["tool_id"], name: "index_games_on_tool_id"
    t.index ["user_id"], name: "index_games_on_user_id"
    t.index ["videos_count"], name: "index_games_on_videos_count"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key", default: "", null: false
    t.index ["key"], name: "index_genres_on_key", unique: true
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "media", force: :cascade do |t|
    t.string "mediable_type", null: false
    t.bigint "mediable_id", null: false
    t.text "description"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "youtube_url"
    t.integer "media_type", default: 0, null: false
    t.index ["mediable_type", "mediable_id", "position"], name: "index_media_on_mediable_type_and_mediable_id_and_position"
    t.index ["mediable_type", "mediable_id"], name: "index_media_on_mediable"
  end

  create_table "news", force: :cascade do |t|
    t.text "text", null: false
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_news_on_game_id"
    t.index ["user_id"], name: "index_news_on_user_id"
  end

  create_table "platforms", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_platforms_on_name", unique: true
    t.index ["slug"], name: "index_platforms_on_slug", unique: true
  end

  create_table "ratings", force: :cascade do |t|
    t.float "rating", default: 0.0, null: false
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_ratings_on_game_id"
    t.index ["user_id", "game_id"], name: "index_ratings_on_user_id_and_game_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "stats", force: :cascade do |t|
    t.integer "downloads", default: 0, null: false
    t.integer "visits", default: 0, null: false
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "created_at"], name: "index_stats_on_game_id_and_created_at", unique: true
    t.index ["game_id"], name: "index_stats_on_game_id"
  end

  create_table "tools", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tools_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "staff", default: false, null: false
    t.integer "notification_count", default: 0, null: false
    t.integer "score", default: 0, null: false
    t.string "given_name"
    t.string "surname"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locale"
    t.string "username"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["locale"], name: "index_users_on_locale"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "download_links", "games"
  add_foreign_key "download_links_platforms", "download_links"
  add_foreign_key "download_links_platforms", "platforms"
  add_foreign_key "followings", "games"
  add_foreign_key "followings", "users"
  add_foreign_key "game_languages", "games"
  add_foreign_key "games", "media", column: "cover_image_id"
  add_foreign_key "news", "games"
  add_foreign_key "news", "users"
  add_foreign_key "ratings", "games"
  add_foreign_key "ratings", "users"
end
