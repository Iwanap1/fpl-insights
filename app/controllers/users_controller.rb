require "open-uri"
require "json"

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

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
  end

  # Returns hash available via @data on user/show
  def collect_current_gw_data
    return {
      bank: @users_api["entry_history"]["bank"].to_f / 10,
      user_players: player_array,
      team_rating: (@user_players.sum { |player| player.general_score } / 15) * 100 * 1.4,
      percentile: ((@general_api["total_players"] - @weekly_ranks.last.to_f) / @general_api["total_players"]) * 100,
      personal_api: JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{@fpl_id}").read),
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
    return {
      all_time_highest: [best_rank, best_season],
      season_points_array: all_points
    }
  end
end
