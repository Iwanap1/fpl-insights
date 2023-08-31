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
  new.minutes = player["minutes"]
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
    new.save
  end
end
