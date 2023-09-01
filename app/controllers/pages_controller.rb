require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def home
  end


  def league_graph
    @general_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/bootstrap-static/").read)
    @current_gw = @general_api["events"].find { |week| week["is_current"] }["id"]
    @league_id = params[:id]
    league_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/leagues-classic/#{@league_id}/standings/").read)
    @league_manager_ids = league_api["standings"]["results"].map{ |user| user["entry"] }
    @league_manager_names = league_api["standings"]["results"].map{ |user| user["player_name"] }
    @graph_data = []
    @league_manager_ids.each do |id|
      @graph_data << get_points_data(id)
    end
  end

  def get_points_data(id)
    user_points_data = []
    history_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/entry/#{id}/history/").read)
    (1..@current_gw).to_a.each do |gw|
      user_points_data << [history_api["current"][gw - 1]["event"], history_api["current"][gw - 1]["total_points"]]
    end
    return user_points_data
  end
end
