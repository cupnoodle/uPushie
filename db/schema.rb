# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160305083115) do

  create_table "rpush_apps", force: :cascade do |t|
    t.string   "name",                    limit: 255,               null: false
    t.string   "environment",             limit: 255
    t.text     "certificate",             limit: 65535
    t.string   "password",                limit: 255
    t.integer  "connections",             limit: 4,     default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                    limit: 255,               null: false
    t.string   "auth_key",                limit: 255
    t.string   "client_id",               limit: 255
    t.string   "client_secret",           limit: 255
    t.string   "access_token",            limit: 255
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id",       limit: 4
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer  "badge",             limit: 4
    t.string   "device_token",      limit: 64
    t.string   "sound",             limit: 255,      default: "default"
    t.string   "alert",             limit: 255
    t.text     "data",              limit: 65535
    t.integer  "expiry",            limit: 4,        default: 86400
    t.boolean  "delivered",         limit: 1,        default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",            limit: 1,        default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code",        limit: 4
    t.text     "error_description", limit: 65535
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alert_is_json",     limit: 1,        default: false
    t.string   "type",              limit: 255,                          null: false
    t.string   "collapse_key",      limit: 255
    t.boolean  "delay_while_idle",  limit: 1,        default: false,     null: false
    t.text     "registration_ids",  limit: 16777215
    t.integer  "app_id",            limit: 4,                            null: false
    t.integer  "retries",           limit: 4,        default: 0
    t.string   "uri",               limit: 255
    t.datetime "fail_after"
    t.boolean  "processing",        limit: 1,        default: false,     null: false
    t.integer  "priority",          limit: 4
    t.text     "url_args",          limit: 65535
    t.string   "category",          limit: 255
  end

  add_index "rpush_notifications", ["app_id", "delivered", "failed", "deliver_after"], name: "index_rapns_notifications_multi", using: :btree
  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", using: :btree

  create_table "students", force: :cascade do |t|
    t.string   "utar_id",            limit: 7,                    null: false
    t.integer  "campus",             limit: 4,        default: 0
    t.string   "device_token",       limit: 64
    t.text     "registration_id",    limit: 16777215
    t.integer  "os",                 limit: 4
    t.datetime "last_login"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "utar_password_hash", limit: 32
  end

  add_index "students", ["utar_id"], name: "index_students_on_utar_id", unique: true, using: :btree

  create_table "subject_students", force: :cascade do |t|
    t.string   "student_utar_id", limit: 7,             null: false
    t.string   "subject_code",    limit: 9,             null: false
    t.integer  "campus",          limit: 4, default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "subject_id",      limit: 4
    t.integer  "student_id",      limit: 4
  end

  add_index "subject_students", ["campus"], name: "index_subject_students_on_campus", using: :btree
  add_index "subject_students", ["student_id"], name: "index_subject_students_on_student_id", using: :btree
  add_index "subject_students", ["student_utar_id", "subject_code", "campus"], name: "unique_utar_id_subject_code_campus", unique: true, using: :btree
  add_index "subject_students", ["student_utar_id"], name: "index_subject_students_on_student_utar_id", using: :btree
  add_index "subject_students", ["subject_code"], name: "index_subject_students_on_subject_code", using: :btree
  add_index "subject_students", ["subject_id"], name: "index_subject_students_on_subject_id", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.string   "code",        limit: 9,                    null: false
    t.integer  "campus",      limit: 4,        default: 0
    t.string   "name",        limit: 128,                  null: false
    t.string   "url",         limit: 128,                  null: false
    t.text     "cached_text", limit: 16777215
    t.string   "latest_hash", limit: 32
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "subjects", ["code", "campus"], name: "index_subjects_on_code_and_campus", unique: true, using: :btree

  add_foreign_key "subject_students", "students"
  add_foreign_key "subject_students", "subjects"
end
