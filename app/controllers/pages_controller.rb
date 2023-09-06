require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def home
    # Uncomment if you need localhost to update DB
    # @players = Player.all
    # UpdateJob.perform_later if (Time.now - @players[-1][:updated_at].to_time) / (60 * 60) > 10
  end


  def league_graph
    @general_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/bootstrap-static/").read)
    @current_gw = @general_api["events"].find { |week| week["is_current"] }["id"]
    @league_id = get_params
    league_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/leagues-classic/#{@league_id}/standings/").read)
    @league_manager_ids = league_api["standings"]["results"].map{ |user| user["entry"] }
    @league_manager_names = league_api["standings"]["results"].map{ |user| user["player_name"] }
    @graph_data = []
    @all_teams = []
    all_user_data = []
    @league_manager_ids.each_with_index do |id, index|
      @graph_data << get_points_data(id)
      user_data = get_user_data(id)
      user_data[:name] = @league_manager_names[index]
      all_user_data << user_data
      @all_teams << get_user_players(id)
    end
    @ranks = get_ranks(all_user_data)
    @player_selections = players_count.sort_by {|player| player[1]}.reverse
    @ownership = ownership
    @pie_data = get_pie
  end

  def get_points_data(id)
    user_points_data = []
    history_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{id}/history/").read)
    history_api["current"].each do |gw|
      user_points_data << [gw["event"], gw["total_points"]]
    end
    return user_points_data
  end

  def get_user_data(id)
    history_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{id}/history/").read)
    user_data = {}
    (1..@current_gw).to_a.each do |gw|
      user_data["#{gw}"] = 0
    end
    history_api["current"].each do |gw|
      user_data["#{gw["event"]}"] = gw["total_points"]
    end
    return user_data
  end

  def get_ranks(all_user_data)
    (1..@current_gw).to_a.each do |gw|
      all_user_data.sort_by { |user| user["#{gw}"] }.reverse.each_with_index do |user, index|
        user["#{gw}"] = index + 1
      end
    end
    all_rank_data = []
    all_user_data.each do |user|
      user_array = []
      (1..@current_gw).each do |gw|
        user_array << [gw, user["#{gw}"]]
      end
      all_rank_data << [user[:name], user_array]
    end
    return all_rank_data
  end

  def get_user_players(id)
    users_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{id}/event/#{@current_gw}/picks/").read)
    latest_team = users_api["picks"]
    players = []
    latest_team.each do |element|
      players << Player.all.find { |p| p.api_id == element["element"] }
    end
    return [id, players]
  end

  def players_count
    groups = @all_teams.map{ |team| team[1] }.flatten.group_by(&:itself)
    groups.map { |value, group| [value, group.count] }
  end

  def ownership
    data = {}
    @player_selections.each do |player|
      data["#{player[0].id}"] = []
      @all_teams.each do |team|
        if team[1].include?(player[0])
          data["#{player[0].id}"] << "#{@league_manager_names[@league_manager_ids.index(team[0])]},"
        end
      end
      data["#{player[0].id}"].last.gsub!(",", "")
    end
    return data
  end

  def user_dash
    @general_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/bootstrap-static/").read)
    @fpl_id = params[:entry]
    @current_gw = @general_api["events"].find { |week| week["is_current"] }["id"]
    @weekly_data = weekly_data
    @weekly_ranks = weekly_data[:weekly_ranks]
    @users_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{@fpl_id}/event/#{@current_gw}/picks/").read)
    @user_players = player_array
    @data = collect_current_gw_data
    @transfer_history_data = JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{@fpl_id}/transfers/").read)
    @historical_data = historical_data
    @graph_data = graph_data
    @bar_chart_data = points_bar_chart
    @price_dist_pie_data = price_dist_pie
    @team_pie_data = team_dist_pie
  end

  def collect_current_gw_data
    return {
      bank: @users_api["entry_history"]["bank"].to_f / 10,
      user_players: player_array,
      team_rating: (@user_players.sum { |player| player.general_score(5) } / 15) * 100 * 1.4,
      percentile: ((@general_api["total_players"] - @weekly_ranks.last.to_f) / @general_api["total_players"]) * 100,
      personal_api: JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{@fpl_id}").read),
      time_till_deadline: (Time.parse(@general_api["events"].find { |week| week["is_next"] }["deadline_time"]) - Time.now),
    }
  end

  def weekly_data
    weekly_overall_ranks = []
    weekly_points = []
    gw_ranks = []
    points_on_bench = []
    captains = []
    chips = 0
    total_transfer_cost = 0
    (1..@current_gw).to_a.each do |gw|
      url = "https://fantasy.premierleague.com/api/entry/#{@fpl_id}/event/#{gw}/picks/"
      data = JSON.parse(URI.open(url).read)
      weekly_overall_ranks << data["entry_history"]["overall_rank"]
      gw_ranks << data["entry_history"]["rank"]
      weekly_points << data["entry_history"]["points"]
      captains << Player.find_by(api_id: data["picks"].find { |p| p["is_captain"] }["element"])
      points_on_bench << data["entry_history"]["points_on_bench"]
      total_transfer_cost += data["entry_history"]["event_transfers_cost"]
      chips += 1 unless data["active_chip"].nil?
    end
    return {
            weekly_ranks: weekly_overall_ranks,
            heighest_points: [weekly_points.max, (weekly_points.index(weekly_points.max) + 1)],
            points_on_bench: points_on_bench,
            number_of_chips: chips,
            gw_ranks: gw_ranks,
            total_transfer_cost: total_transfer_cost,
            captains: captains.map { |p| [p.web_name, captains.count { |pl| pl.id == p.id }] }.uniq
           }
  end

  def player_array
    latest_picks = @users_api["picks"]
    all_players = Player.all
    players = []
    latest_picks.each do |element|
      players << all_players.find { |p| p.api_id == element["element"] }
    end
    return players.sort_by { |p| p.general_score(5) }
  end

  def graph_data
    data = []
    @weekly_ranks.each_with_index do |rank, i|
      data << [(i + 1), rank]
    end
    return data
  end

  def points_bar_chart
    data = []
    @historical_data[:season_points_array].each_with_index do |points, i|
      data << [(i + 1), points]
    end
    return data
  end

  def price_dist_pie
    fors = @user_players.select { |p| p.position == "FOR" }.sum{ |p| p.price }.round(1)
    mids = @user_players.select { |p| p.position == "MID" }.sum{ |p| p.price }.round(1)
    defs = @user_players.select { |p| p.position == "DEF" }.sum{ |p| p.price }.round(1)
    gkps = @user_players.select { |p| p.position == "GKP" }.sum{ |p| p.price }.round(1)
    return [["Forwards", fors], ["Midfielders", mids], ["Defenders", defs], ["Goalkeepers", gkps]]
  end

  def team_dist_pie
    grouped = @user_players.group_by { |player| player.home_team }
    pie_data = []
    grouped.each do |key, value|
      pie_data << [key.name, value.count]
    end
    return pie_data
  end



  private

  def get_params
    params[:id]
  end

  def set_user
    @user = User.find(params[:id])
  end

  def historical_data
    history_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{@fpl_id}/history/").read)
    past_array = history_api["past"]
    if past_array.empty?
      best_rank = @weekly_ranks.last
      best_season = "current"
    else
      best_rank = past_array.min { |a, b| a["rank"] <=> b["rank"] }["rank"]
      best_season = past_array.min { |a, b| a["rank"] <=> b["rank"] }["season_name"]
    end
    all_points = history_api["current"].map { |w| w["points"] }
    best_score = past_array.empty? ? nil : past_array.max { |a, b| a["total_points"] <=> b["total_points"] }["total_points"]
    best_score_season = past_array.empty? ? nil : past_array.max { |a, b| a["total_points"] <=> b["total_points"] }["season_name"]
    return {
      all_time_highest: [best_rank, best_season],
      season_points_array: all_points,
      best_score: [best_score, best_score_season],
      heighest_percentile: get_percentiles(past_array)[1],
      avg_percentile: get_percentiles(past_array)[0],
      count: past_array.length,
      avg_rank: past_array.empty? ? 0 : (past_array.map{ |s| s["rank"] }.sum.to_f / past_array.count).round,
      avg_score: past_array.empty? ? 0 : (past_array.map{ |s| s["total_points"] }.sum.to_f / past_array.count).round
    }
  end

  def get_percentiles(past_array)
    if past_array.empty?
      result = []
      highest = 0
    else
      past_number_players = [
                              1_270_000, 1_700_000, 1_950_000, 2_100_000, 2_350_000, 2_510_000, 2_608_634, 3_218_998,
                              3_502_998, 3_734_001, 4_503_345, 5_190_135, 6_324_237, 7_628_968, 8_153_044, 9_167_407, 11_400_000
                            ].reverse
      percentiles_sum = 0
      past_array.map { |s| s["rank"]}.reverse.each_with_index do |season, index|
        percentiles_sum += ((past_number_players[index] - season.to_f) / past_number_players[index])
      end
      highest = past_array.map.with_index { |s, index| ((past_number_players[index] - s["rank"].to_f) / past_number_players[index]) }.max
      result = ((percentiles_sum / past_array.count) * 100).round(1)
    end
    return [result, highest]
  end


  def get_pie
    first_count = {}
    @ranks.each do |user|
      user_sum = 0
      user[1].each do |ranks|
        user_sum += 1 if ranks[1] == 1
      end
      first_count["#{user[0]}"] = user_sum unless user_sum.zero?
    end
    return first_count
  end
end
