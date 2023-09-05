require 'open-uri'
require 'json'

class Fixture < ApplicationRecord
  belongs_to :home_team
  belongs_to :away_team

  def start_time
    self.date
  end

  def self.update_all
    fixture_url = "https://fantasy.premierleague.com/api/fixtures/"
    fixture_info = JSON.parse(URI.open(fixture_url).read)
    Fixture.all.each do |fixture|
      api_fixture = fixture_info.find { |f| f["team_a"] == fixture.away_team_id && f["team_h"] == fixture.home_team_id }
      fixture.date = Date.parse(api_fixture["kickoff_time"].split("T")[0])
      # Continue here, fixture == db, api_fixture == api
      fixture.finished = api_fixture["finished"]
      if fixture.finished
        fixture.home_team_score = api_fixture["team_h_score"]
        fixture.away_team_score = api_fixture["team_a_score"]
        api_fixture["stats"].each do |game|
          if game["identifier"] == "goals_scored"
            a_goals = ""
            game["a"].each do |a|
              player = Player.find_by(api_id: a["element"])
              a_goals << "#{player.web_name}(#{a['value']}),"
            end
            fixture.away_goals = a_goals
            h_goals = ""
            game["h"].each do |h|
              player = Player.find_by(api_id: h["element"])
              h_goals << "#{player.web_name}(#{h['value']}),"
            end
            fixture.home_goals = h_goals
          end
          if game["identifier"] == "assists"
            a_assists = ""
            game["a"].each do |a|
              player = Player.find_by(api_id: a["element"])
              a_assists << "#{player.web_name}(#{a['value']}),"
            end
            fixture.away_assists = a_assists
            h_assists = ""
            game["h"].each do |h|
              player = Player.find_by(api_id: h["element"])
              h_assists << "#{player.web_name}(#{h['value']}),"
            end
            fixture.home_assists = h_assists
          end
          if game["identifier"] == "own_goals"
            a_own_goals = ""
            game["a"].each do |a|
              player = Player.find_by(api_id: a["element"])
              a_own_goals << "#{player.web_name}(#{a['value']}),"
            end
            fixture.away_own_goals = a_own_goals
            h_own_goals = ""
            game["h"].each do |h|
              player = Player.find_by(api_id: h["element"])
              h_own_goals << "#{player.web_name}(#{h['value']}),"
            end
            fixture.home_own_goals = h_own_goals
          end
          if game["identifier"] == "penalties_saved"
            a_penalties_saved = ""
            game["a"].each do |a|
              player = Player.find_by(api_id: a["element"])
              a_penalties_saved << "#{player.web_name}(#{a['value']}),"
            end
            fixture.away_penalties_saved = a_penalties_saved
            h_penalties_saved = ""
            game["h"].each do |h|
              player = Player.find_by(api_id: h["element"])
              h_penalties_saved << "#{player.web_name}(#{h['value']}),"
            end
            fixture.home_penalties_saved = h_penalties_saved
          end
          if game["identifier"] == "penalties_missed"
            a_penalties_missed = ""
            game["a"].each do |a|
              player = Player.find_by(api_id: a["element"])
              a_penalties_missed << "#{player.web_name}(#{a['value']}),"
            end
            fixture.away_penalties_missed = a_penalties_missed
            h_penalties_missed = ""
            game["h"].each do |h|
              player = Player.find_by(api_id: h["element"])
              h_penalties_missed << "#{player.web_name}(#{h['value']}),"
            end
            fixture.home_penalties_missed = h_penalties_missed
          end
          if game["identifier"] == "yellow_cards"
            a_yellow_cards = ""
            game["a"].each do |a|
              player = Player.find_by(api_id: a["element"])
              a_yellow_cards << "#{player.web_name}(#{a['value']}),"
            end
            fixture.away_yellow_cards = a_yellow_cards
            h_yellow_cards = ""
            game["h"].each do |h|
              player = Player.find_by(api_id: h["element"])
              h_yellow_cards << "#{player.web_name}(#{h['value']}),"
            end
            fixture.home_yellow_cards = h_yellow_cards
          end
          if game["identifier"] == "red_cards"
            a_red_cards = ""
            game["a"].each do |a|
              player = Player.find_by(api_id: a["element"])
              a_red_cards << "#{player.web_name}(#{a['value']}),"
            end
            fixture.away_red_cards = a_red_cards
            h_red_cards = ""
            game["h"].each do |h|
              player = Player.find_by(api_id: h["element"])
              h_red_cards << "#{player.web_name}(#{h['value']}),"
            end
            fixture.home_red_cards = h_red_cards
          end
          if game["identifier"] == "saves"
            a_saves = ""
            game["a"].each do |a|
              player = Player.find_by(api_id: a["element"])
              a_saves << "#{player.web_name}(#{a['value']}),"
            end
            fixture.away_saves = a_saves
            h_saves = ""
            game["h"].each do |h|
              player = Player.find_by(api_id: h["element"])
              h_saves << "#{player.web_name}(#{h['value']}),"
            end
            fixture.home_saves = h_saves
          end
          if game["identifier"] == "bonus"
            a_bonus = ""
            game["a"].each do |a|
              player = Player.find_by(api_id: a["element"])
              a_bonus << "#{player.web_name}(#{a['value']}),"
            end
            fixture.away_bonus = a_bonus
            h_bonus = ""
            game["h"].each do |h|
              player = Player.find_by(api_id: h["element"])
              h_bonus << "#{player.web_name}(#{h['value']}),"
            end
            fixture.home_bonus = h_bonus
          end
        end
      else
       fixture.gameweek_number = api_fixture["event"] unless api_fixture["event"].to_i == 0
      end
      fixture.save
    end
  end
end
