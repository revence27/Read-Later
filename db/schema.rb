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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120714173549) do

  create_table "saved_blogs", :force => true do |t|
    t.text     "name"
    t.text     "by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saved_comments", :force => true do |t|
    t.text     "author"
    t.text     "author_url"
    t.datetime "published_at"
    t.text     "content"
    t.integer  "saved_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "commentid"
  end

  create_table "saved_images", :force => true do |t|
    t.text     "resource_b64"
    t.text     "content_type"
    t.text     "original"
    t.text     "suggested_name"
    t.integer  "saved_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saved_posts", :force => true do |t|
    t.text     "title"
    t.text     "html"
    t.datetime "when"
    t.boolean  "seen"
    t.integer  "saved_blog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "original"
    t.text     "picture"
    t.integer  "comment_count", :default => 0
  end

end
