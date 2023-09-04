require "open-uri"
require "json"

class PlayersController < ApplicationController
  def index
    @players = Player.all
    @players = Player.all
    @filtered = @players.select { |p| p.position == params[:position] || params[:position] == "all" }.select { |p| p.price <= params[:price].to_f || params[:price] == "all"}
    if params[:position] && params[:price]
      @ranked = @filtered.sort_by { |p| p.general_score }.reverse
    else
      @ranked = @players.sort_by(&:general_score).reverse
    end
    @params = [params[:position], params[:price]]
  end

  def show
    @player = Player.find(params[:id])
    @home_fixtures = @player.home_team.fixtures
    @away_fixtures = @player.away_team.fixtures
    @all_fixtures = [@home_fixtures, @away_fixtures].flatten
    general_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/bootstrap-static/").read)
    @current_gw = general_api["events"].find { |week| week["is_current"] }["id"]
    @attributes = @player.attributes(@current_gw)
    @previous_three_data = past_three_gw_data
  end

  # def fixtures(id) NOW IN PLAYER MODEL
  #   url = "https://fantasy.premierleague.com/api/element-summary/#{id}/"
  #   fixtures = JSON.parse(URI.open(url).read)["fixtures"]
  #   difficulties = []
  #   fixtures.first(5).each do |fixture|
  #     difficulties << fixture["difficulty"].to_i
  #   end
  #   return difficulties.sum
  # end

  def past_three_gw_data
    individual_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/element-summary/#{@player.api_id}/").read)
    data = []
    individual_api["history"].last(3).each do |match|
      data << {
        points: match["total_points"],
        goals: match["goals_scored"],
        assists: match["assists"],
        minutes: match["minutes"],
        opponent: match["opponent_team"]
      }
    end
    return data
  end


end
