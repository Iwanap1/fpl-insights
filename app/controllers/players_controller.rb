require "open-uri"
require "json"

class PlayersController < ApplicationController
  def index
    @players = Player.all
    @max = @players.max { |a,b| a.price <=> b.price}
    @filtered = @players.select { |p| p.position == position_params[0] || position_params[0] == "all players" }.select { |p| p.price <= params[:price].to_f || params[:price] == "all"}
    if params[:sliderValue]
      if params[:position] && params[:price]
        @ranked = @filtered.sort_by { |p| p.general_score(params[:sliderValue].to_i) }.reverse
      else
        @ranked = @players.sort_by{ |p| p.general_score(params[:sliderValue].to_i) }.reverse
      end
    else
      if params[:position] && params[:price]
        @ranked = @filtered.sort_by { |p| p.general_score(5) }.reverse
      else
        @ranked = @players.sort_by{ |p| p.general_score(5) }.reverse
      end
    end
    @params = [position_params, params[:price], params[:sliderValue]]
  end

  def show
    @player = Player.find(params[:id])
    @home_fixtures = @player.home_team.fixtures
    @away_fixtures = @player.away_team.fixtures
    @all_fixtures = [@home_fixtures, @away_fixtures].flatten
    general_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/bootstrap-static/").read)
    @player_api_data = general_api["elements"].find { |e| e["id"] == @player.api_id }
    @current_gw = general_api["events"].find { |week| week["is_current"] }["id"]
    @attributes = @player.attributes(@current_gw)
    @previous_three_data = past_three_gw_data
    @stats = show_stats(general_api["elements"])
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

  def show_stats(elements)
    case @player.position
    when "FOR"
      return [["Goals", @player.goals],
              ["Assists", @player.assists],
              ["Average Minutes", @player.minutes / @current_gw],
              ["GW Transfers Out", elements.find { |e| e["id"] == @player.api_id }["transfers_out_event"]],
              ["GW Transfers In", @player.transfers_in],
              ["Rating", @player.general_score(5) * 100]
            ]
    when "MID"
      return [["Goals", @player.goals],
              ["Assists", @player.assists],
              ["Average Minutes", @player.minutes / @current_gw],
              ["GW Transfers Out", elements.find { |e| e["id"] == @player.api_id }["transfers_out_event"]],
              ["GW Transfers In", @player.transfers_in],
              ["Rating", @player.general_score(5) * 100]
              ]
    when "DEF"
      return [["Clean Sheets", elements.find { |e| e["id"] == @player.api_id }["clean_sheets"]],
              ["Goal Involvements", @player.assists + @player.goals],
              ["Average Minutes", @player.minutes / @current_gw],
              ["GW Transfers Out", elements.find { |e| e["id"] == @player.api_id }["transfers_out_event"]],
              ["GW Transfers In", @player.transfers_in],
              ["Rating", @player.general_score(5) * 100]
            ]
    when "GKP"
      return [["Clean Sheets", elements.find { |e| e["id"] == @player.api_id }["clean_sheets"]],
              ["Saved Penalties", elements.find { |e| e["id"] == @player.api_id }["penalties_saved"]],
              ["Average Minutes", @player.minutes / @current_gw],
              ["GW Transfers Out", elements.find { |e| e["id"] == @player.api_id }["transfers_out_event"]],
              ["GW Transfers In", @player.transfers_in],
              ["Rating", @player.general_score(5) * 100]
            ]
    end
  end

  def position_params
    if params["position"]
      case params["position"]
      when "0" then return ["GKP", "goalkeepers", 0]
      when "1" then return ["DEF", "defenders", 1]
      when "2" then return ["MID", "midfielders", 2]
      when "3" then return ["FOR", "forwards", 3]
      else
        return ["all players"]
      end
    else
      return ["all players"]
    end
  end
end
