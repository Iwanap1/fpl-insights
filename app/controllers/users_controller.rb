require "open-uri"
require "json"

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    @User = User.find(params[:id])
    @fpl_id = 7090474
    @team_strengths = [] # Fetch player strengths here
    @team_weaknesses = [] # Fetch player weaknesses here
    @current_gw = JSON.parse(URI.open(general_url).read)["events"].find { |week| week["is_current"] }["id"]
    @weekly_ranks = weekly_ranks_array
    user_url = "https://fantasy.premierleague.com/api/entry/#{@fpl_id}/event/#{@current_gw}/picks/"
    @user_players = player_array
    @rating = (@user_players.sum { |player| player.general_score } / 15) * 100 * 1.4
    @bank = JSON.parse(URI.open(user_url).read)["entry_history"]["bank"].to_f / 10
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
    url = "https://fantasy.premierleague.com/api/entry/#{@fpl_id}/event/#{@current_gw}/picks/"
    latest_picks = JSON.parse(URI.open(url).read)["picks"]
    all_players = Player.all
    players = []
    latest_picks.each do |element|
      players << all_players.find { |p| p.api_id == element["element"] }
    end
    return players.sort_by { |p| p.general_score }.reverse
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
