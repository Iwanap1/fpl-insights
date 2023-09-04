# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
general_info = JSON.parse(URI.open(general_url).read)
fixture_url = "https://fantasy.premierleague.com/api/fixtures/"
fixture_info = JSON.parse(URI.open(fixture_url).read)

general_info["teams"].each_with_index do |team, index|
  new = HomeTeam.new
  new.name = team["name"]
  new.short_name = team["short_name"]
  new.difficulty = team["strength"]
  new.image_path = "#{index + 1}.png"
  new.save
end

general_info["teams"].each_with_index do |team, index|
  new = AwayTeam.new
  new.name = team["name"]
  new.short_name = team["short_name"]
  new.difficulty = team["strength"]
  new.image_path = "#{index + 1}.png"
  new.save
end

general_info["elements"].each_with_index do |player, index|
  new = Player.new
  new.first_name = player["first_name"]
  new.last_name = player["second_name"]
  if player["element_type"] == 1
    new.position = "GKP"
  elsif player["element_type"] == 2
    new.position = "DEF"
  elsif player["element_type"] == 3
    new.position = "MID"
  else
    new.position = "FOR"
  end
  new.away_team_id = player["team"]
  new.home_team_id = player["team"]
  new.api_id = player["id"]
  new.form = player["form"]
  new.price = player["now_cost"].to_f / 10
  new.web_name = player["web_name"]
  new.ict = player["ict_index"].to_f
  new.selected = player["selected_by_percent"]
  new.chance = player["chance_of_playing_next_round"].to_f / 100
  new.expected_goal_involvements = player["expected_goal_involvements_per_90"].to_f
  new.expected_goals_conceded = player["expected_goal_conceded_per_90"].to_f
  new.transfers_in = player["transfers_in_event"]
  new.penalty_order = player["penalties_order"].nil? ? 5 : player["penalties_order"]
  new.free_kick_order = player["direct_freekicks_order"].nil? ? 5 : player["direct_freekicks_order"]
  new.minutes = player["minutes"]
  new.goals = player["goals_scored"]
  new.assists = player["assists"]
  new.total = player["total_points"]
  new.save
  new.fixture_difficulty = new.fixtures[:fixture_difficulty]
  new.previous_points = new.fixtures[:previous_points]
  new.save
end

fixture_info.each do |fixture|
  unless fixture["event"].to_i == 0
    new = Fixture.new
    new.home_team_id = fixture["team_h"]
    new.away_team_id = fixture["team_a"]
    new.gameweek_number = fixture["event"]
    new.date = Date.parse(fixture["kickoff_time"].split("T")[0])
    new.finished = fixture["finished"]
    new.home_team_score = fixture["team_h_score"]
    new.away_team_score = fixture["team_a_score"]
      fixture["stats"].each do |game|
        if game["identifier"] == "goals_scored"
          a_goals = ""
          game["a"].each do |a|
            player = Player.find_by(api_id: a["element"])
            a_goals << "#{player.web_name}(#{a['value']}),"
          end
          new.away_goals = a_goals
          h_goals = ""
          game["h"].each do |h|
            player = Player.find_by(api_id: h["element"])
            h_goals << "#{player.web_name}(#{h['value']}),"
          end
          new.home_goals = h_goals
        end
        if game["identifier"] == "assists"
          a_assists = ""
          game["a"].each do |a|
            player = Player.find_by(api_id: a["element"])
            a_assists << "#{player.web_name}(#{a['value']}),"
          end
          new.away_assists = a_assists
          h_assists = ""
          game["h"].each do |h|
            player = Player.find_by(api_id: h["element"])
            h_assists << "#{player.web_name}(#{h['value']}),"
          end
          new.home_assists = h_assists
        end
        if game["identifier"] == "own_goals"
          a_own_goals = ""
          game["a"].each do |a|
            player = Player.find_by(api_id: a["element"])
            a_own_goals << "#{player.web_name}(#{a['value']}),"
          end
          new.away_own_goals = a_own_goals
          h_own_goals = ""
          game["h"].each do |h|
            player = Player.find_by(api_id: h["element"])
            h_own_goals << "#{player.web_name}(#{h['value']}),"
          end
          new.home_own_goals = h_own_goals
        end
        if game["identifier"] == "penalties_saved"
          a_penalties_saved = ""
          game["a"].each do |a|
            player = Player.find_by(api_id: a["element"])
            a_penalties_saved << "#{player.web_name}(#{a['value']}),"
          end
          new.away_penalties_saved = a_penalties_saved
          h_penalties_saved = ""
          game["h"].each do |h|
            player = Player.find_by(api_id: h["element"])
            h_penalties_saved << "#{player.web_name}(#{h['value']}),"
          end
          new.home_penalties_saved = h_penalties_saved
        end
        if game["identifier"] == "penalties_missed"
          a_penalties_missed = ""
          game["a"].each do |a|
            player = Player.find_by(api_id: a["element"])
            a_penalties_missed << "#{player.web_name}(#{a['value']}),"
          end
          new.away_penalties_missed = a_penalties_missed
          h_penalties_missed = ""
          game["h"].each do |h|
            player = Player.find_by(api_id: h["element"])
            h_penalties_missed << "#{player.web_name}(#{h['value']}),"
          end
          new.home_penalties_missed = h_penalties_missed
        end
        if game["identifier"] == "yellow_cards"
          a_yellow_cards = ""
          game["a"].each do |a|
            player = Player.find_by(api_id: a["element"])
            a_yellow_cards << "#{player.web_name}(#{a['value']}),"
          end
          new.away_yellow_cards = a_yellow_cards
          h_yellow_cards = ""
          game["h"].each do |h|
            player = Player.find_by(api_id: h["element"])
            h_yellow_cards << "#{player.web_name}(#{h['value']}),"
          end
          new.home_yellow_cards = h_yellow_cards
        end
        if game["identifier"] == "red_cards"
          a_red_cards = ""
          game["a"].each do |a|
            player = Player.find_by(api_id: a["element"])
            a_red_cards << "#{player.web_name}(#{a['value']}),"
          end
          new.away_red_cards = a_red_cards
          h_red_cards = ""
          game["h"].each do |h|
            player = Player.find_by(api_id: h["element"])
            h_red_cards << "#{player.web_name}(#{h['value']}),"
          end
          new.home_red_cards = h_red_cards
        end
        if game["identifier"] == "saves"
          a_saves = ""
          game["a"].each do |a|
            player = Player.find_by(api_id: a["element"])
            a_saves << "#{player.web_name}(#{a['value']}),"
          end
          new.away_saves = a_saves
          h_saves = ""
          game["h"].each do |h|
            player = Player.find_by(api_id: h["element"])
            h_saves << "#{player.web_name}(#{h['value']}),"
          end
          new.home_saves = h_saves
        end
        if game["identifier"] == "bonus"
          a_bonus = ""
          game["a"].each do |a|
            player = Player.find_by(api_id: a["element"])
            a_bonus << "#{player.web_name}(#{a['value']}),"
          end
          new.away_bonus = a_bonus
          h_bonus = ""
          game["h"].each do |h|
            player = Player.find_by(api_id: h["element"])
            h_bonus << "#{player.web_name}(#{h['value']}),"
          end
          new.home_bonus = h_bonus
        end
      end
     new.save
  end
end
