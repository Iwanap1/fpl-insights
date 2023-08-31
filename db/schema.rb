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

ActiveRecord::Schema[7.0].define(version: 2023_08_31_132108) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "away_teams", force: :cascade do |t|
    t.string "name"
    t.integer "difficulty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
    t.string "image_path"
  end

  create_table "fixtures", force: :cascade do |t|
    t.bigint "home_team_id", null: false
    t.bigint "away_team_id", null: false
    t.date "date"
    t.integer "gameweek_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "finished"
    t.integer "home_team_score"
    t.integer "away_team_score"
    t.index ["away_team_id"], name: "index_fixtures_on_away_team_id"
    t.index ["home_team_id"], name: "index_fixtures_on_home_team_id"
  end

  create_table "home_teams", force: :cascade do |t|
    t.string "name"
    t.integer "difficulty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
    t.string "image_path"
  end

  create_table "players", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.bigint "away_team_id", null: false
    t.bigint "home_team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "api_id"
    t.float "form"
    t.float "selected"
    t.integer "ict"
    t.string "web_name"
    t.float "price"
    t.integer "fixture_difficulty"
    t.float "chance"
    t.integer "transfers_in"
    t.integer "penalty_order"
    t.float "expected_goal_involvements"
    t.float "expected_goals_conceded"
    t.integer "minutes"
    t.integer "goals"
    t.integer "assists"
    t.index ["away_team_id"], name: "index_players_on_away_team_id"
    t.index ["home_team_id"], name: "index_players_on_home_team_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fantasy_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "fixtures", "away_teams"
  add_foreign_key "fixtures", "home_teams"
  add_foreign_key "players", "away_teams"
  add_foreign_key "players", "home_teams"
end
