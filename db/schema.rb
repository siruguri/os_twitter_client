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

ActiveRecord::Schema.define(version: 20161021050635) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"

  create_table "account_entries", force: :cascade do |t|
    t.float    "entry_amount"
    t.string   "merchant_name"
    t.datetime "entry_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "account_entries_tags", force: :cascade do |t|
    t.integer  "transaction_tag_id"
    t.integer  "account_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "article_taggings", force: :cascade do |t|
    t.integer  "article_tag_id"
    t.integer  "web_article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "article_tags", force: :cascade do |t|
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channel_post_redirect_maps", force: :cascade do |t|
    t.integer  "channel_post_id"
    t.integer  "redirect_map_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channel_posts", force: :cascade do |t|
    t.string   "url"
    t.text     "message"
    t.string   "tweet_tags"
    t.string   "short_message"
    t.datetime "last_posted_at"
    t.string   "redirect_url"
    t.integer  "total_post_count"
    t.string   "post_strategy"
    t.boolean  "post_again"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "channel_secrets", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "secret_for"
    t.text     "secrets_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configs", force: :cascade do |t|
    t.string   "config_key"
    t.text     "config_value"
    t.string   "config_value_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_universes", force: :cascade do |t|
    t.text     "universe"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graph_connections", force: :cascade do |t|
    t.bigint   "leader_id"
    t.bigint   "follower_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["follower_id"], name: "index_graph_connections_on_follower_id", using: :btree
    t.index ["leader_id"], name: "index_leader_id_on_profile_followers", using: :btree
  end

  create_table "job_records", force: :cascade do |t|
    t.string   "job_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "job_name"
  end

  create_table "media_records", force: :cascade do |t|
    t.string   "channel_id"
    t.string   "channel_name"
    t.integer  "channel_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_token_hashes", force: :cascade do |t|
    t.string   "source"
    t.string   "token"
    t.string   "secret"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "request_token"
  end

  create_table "profile_stats", force: :cascade do |t|
    t.integer  "twitter_profile_id"
    t.jsonb    "stats_hash_v2",        default: {}, null: false
    t.datetime "most_recent_tweet_at"
    t.datetime "most_old_tweet_at"
    t.index ["stats_hash_v2"], name: "index_profile_stats_on_stats_hash_v2", using: :gin
    t.index ["twitter_profile_id"], name: "index_profile_stats_on_twitter_profile_id", using: :btree
  end

  create_table "redirect_maps", force: :cascade do |t|
    t.string   "src"
    t.string   "dest"
    t.integer  "redirect_requests_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "redirect_requests", force: :cascade do |t|
    t.integer  "redirect_map_id"
    t.string   "request_agent"
    t.string   "request_referer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_tags", force: :cascade do |t|
    t.string   "tag_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tweets", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint   "twitter_id"
    t.datetime "tweeted_at"
    t.jsonb    "tweet_details", default: {}, null: false
    t.text     "mesg"
    t.bigint   "tweet_id"
    t.boolean  "is_retweeted"
    t.boolean  "processed"
    t.index ["processed"], name: "index_tweets_on_processed", using: :btree
    t.index ["tweet_id"], name: "index_tweets_on_tweet_id", unique: true, using: :btree
    t.index ["tweeted_at"], name: "index_tweets_on_tweeted_at", using: :btree
    t.index ["twitter_id"], name: "index_tweets_on_twitter_id", using: :btree
  end

  create_table "twitter_profiles", force: :cascade do |t|
    t.string   "handle"
    t.string   "location"
    t.string   "bio"
    t.datetime "member_since"
    t.string   "website"
    t.integer  "num_followers"
    t.integer  "num_following"
    t.integer  "num_tweets"
    t.integer  "num_favorites"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "last_tweet"
    t.integer  "tweets_count",    default: 0
    t.bigint   "twitter_id"
    t.datetime "last_tweet_time"
    t.integer  "user_id"
    t.text     "word_cloud"
    t.boolean  "protected"
    t.string   "display_name"
    t.index ["last_tweet_time"], name: "index_twitter_profiles_on_last_tweet_time", using: :btree
    t.index ["twitter_id"], name: "index_twitter_profiles_on_twitter_id", using: :btree
    t.index ["user_id"], name: "index_twitter_profiles_on_user_id", unique: true, using: :btree
  end

  create_table "twitter_request_records", force: :cascade do |t|
    t.string   "handle"
    t.bigint   "cursor"
    t.string   "request_type"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ran_limit"
    t.string   "request_for"
    t.string   "status_message"
    t.bigint   "prev_cursor"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unconfirmed_email"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "web_articles", force: :cascade do |t|
    t.string   "source"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author"
    t.string   "original_url"
    t.integer  "twitter_profile_id"
    t.boolean  "fetch_failed"
    t.index ["original_url"], name: "index_original_url_on_web_articles", unique: true, using: :btree
    t.index ["twitter_profile_id"], name: "index_web_articles_on_twitter_profile_id", using: :btree
  end

end
