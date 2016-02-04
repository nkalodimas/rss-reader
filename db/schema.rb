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

ActiveRecord::Schema.define(version: 20160116142548) do

  create_table "entries", force: :cascade do |t|
    t.string   "title"
    t.string   "link"
    t.string   "summary"
    t.datetime "pub_date"
    t.string   "entryId"
    t.integer  "feed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "entries", ["feed_id"], name: "index_entries_on_feed_id"

  create_table "feeds", force: :cascade do |t|
    t.string   "title"
    t.string   "link"
    t.string   "description"
    t.datetime "updated"
    t.integer  "type"
    t.string   "icon"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "feeds", ["link"], name: "index_feeds_on_link", unique: true

  create_table "feeds_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "feed_id"
  end

  add_index "feeds_users", ["feed_id"], name: "index_feeds_users_on_feed_id"
  add_index "feeds_users", ["user_id"], name: "index_feeds_users_on_user_id"

  create_table "reads", force: :cascade do |t|
    t.boolean  "read",       default: false
    t.integer  "user_id"
    t.integer  "entry_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "reads", ["entry_id"], name: "index_reads_on_entry_id"
  add_index "reads", ["user_id"], name: "index_reads_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "last_login"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
