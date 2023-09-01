require "open-uri"
require "json"

class UsersController < ApplicationController
  # before_action :authenticate_user!
  # before_action :set_user

  def show
    @general_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/bootstrap-static/").read)
    @user = User.find(params[:id])
    @fpl_id = @user.fantasy_id
    @current_gw = @general_api["events"].find { |week| week["is_current"] }["id"]
    @weekly_ranks = weekly_ranks_array
    @users_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{@fpl_id}/event/#{@current_gw}/picks/").read)
    @user_players = player_array
    @data = collect_current_gw_data
    @historical_data = historical_data
    @graph_data = graph_data
    @bar_chart_data = points_bar_chart
    @price_dist_pie_data = price_dist_pie
    @team_pie_data = team_dist_pie
  end

  # Returns hash available via @data on user/show
  def collect_current_gw_data
    return {
      bank: @users_api["entry_history"]["bank"].to_f / 10,
      user_players: player_array,
      team_rating: (@user_players.sum { |player| player.general_score } / 15) * 100 * 1.4,
      percentile: ((@general_api["total_players"] - @weekly_ranks.last.to_f) / @general_api["total_players"]) * 100,
      personal_api: JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{@fpl_id}").read),
      time_till_deadline: (Time.parse(@general_api["events"].find { |week| week["is_next"] }["deadline_time"]) - Time.now)
    }
  end

  def weekly_ranks_array
    weekly_ranks = []
    (1..@current_gw).to_a.each do |gw|
      url = "https://fantasy.premierleague.com/api/entry/#{@fpl_id}/event/#{gw}/picks/"
      weekly_ranks << JSON.parse(URI.open(url).read)["entry_history"]["overall_rank"]
    end
    return weekly_ranks
  end

  def player_array
    latest_picks = @users_api["picks"]
    all_players = Player.all
    players = []
    latest_picks.each do |element|
      players << all_players.find { |p| p.api_id == element["element"] }
    end
    return players.sort_by { |p| p.general_score }
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
end
