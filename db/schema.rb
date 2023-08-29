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

ActiveRecord::Schema[7.0].define(version: 2023_08_29_094325) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "away_teams", force: :cascade do |t|
    t.string "name"
    t.integer "difficulty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
  end

  create_table "fixtures", force: :cascade do |t|
    t.bigint "home_team_id", null: false
    t.bigint "away_team_id", null: false
    t.date "date"
    t.integer "gameweek_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_fixtures_on_away_team_id"
    t.index ["home_team_id"], name: "index_fixtures_on_home_team_id"
  end

  create_table "home_teams", force: :cascade do |t|
    t.string "name"
    t.integer "difficulty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
  end

  create_table "players", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.bigint "away_team_id", null: false
    t.bigint "home_team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_players_on_away_team_id"
    t.index ["home_team_id"], name: "index_players_on_home_team_id"
  end

  add_foreign_key "fixtures", "away_teams"
  add_foreign_key "fixtures", "home_teams"
  add_foreign_key "players", "away_teams"
  add_foreign_key "players", "home_teams"
end
