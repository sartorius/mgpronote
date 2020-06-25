# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_25_102457) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "barcode", force: :cascade do |t|
    t.string "ref_tag", limit: 20, null: false
    t.integer "secure", limit: 2, null: false
    t.integer "secret_code", limit: 2, null: false
    t.integer "status", limit: 2, default: 0
    t.string "to_email", limit: 200
    t.string "to_name", limit: 50
    t.string "to_fname", limit: 50
    t.string "to_phone", limit: 50
    t.datetime "create_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "microposts", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "created_at"], name: "index_microposts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_microposts_on_user_id"
  end

  create_table "mod_workflow", id: :serial, force: :cascade do |t|
    t.integer "wkf_id", limit: 2, null: false
    t.integer "start_id", limit: 2, null: false
    t.integer "end_id", limit: 2, null: false
    t.datetime "create_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "ref_status", id: :integer, limit: 2, default: nil, force: :cascade do |t|
    t.string "step", limit: 50, null: false
    t.string "description", limit: 250, null: false
    t.string "input_needed", limit: 1, null: false
    t.datetime "create_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "ref_workflow", id: :integer, limit: 2, default: nil, force: :cascade do |t|
    t.string "code", limit: 2, null: false
    t.string "description", limit: 250, null: false
    t.datetime "create_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["followed_id"], name: "index_relationships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_relationships_on_follower_id"
  end

  create_table "tag", force: :cascade do |t|
    t.string "bc", limit: 50, null: false
    t.string "step", limit: 100, null: false
    t.string "geo", limit: 200, null: false
    t.datetime "create_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.boolean "owner", default: false
    t.integer "partner", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wk_tag", force: :cascade do |t|
    t.bigint "bc_id", null: false
    t.integer "mwkf_id", limit: 2, null: false
    t.integer "current_step_id", limit: 2, null: false
    t.string "geo_l", limit: 250, default: "N"
    t.boolean "is_incident", default: false
    t.datetime "create_date", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "wk_tag_com", force: :cascade do |t|
    t.bigint "wk_tag_id", null: false
    t.string "comment", limit: 500
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "microposts", "users"
  add_foreign_key "mod_workflow", "ref_status", column: "end_id", name: "mod_workflow_end_id_fkey"
  add_foreign_key "mod_workflow", "ref_status", column: "start_id", name: "mod_workflow_start_id_fkey"
  add_foreign_key "mod_workflow", "ref_workflow", column: "wkf_id", name: "mod_workflow_wkf_id_fkey"
  add_foreign_key "wk_tag", "barcode", column: "bc_id", name: "wk_tag_bc_id_fkey"
  add_foreign_key "wk_tag", "mod_workflow", column: "mwkf_id", name: "wk_tag_mwkf_id_fkey"
  add_foreign_key "wk_tag", "ref_status", column: "current_step_id", name: "wk_tag_current_step_id_fkey"
  add_foreign_key "wk_tag_com", "wk_tag", name: "wk_tag_com_wk_tag_id_fkey"
end
