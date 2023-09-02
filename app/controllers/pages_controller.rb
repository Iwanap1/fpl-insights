require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def home
    # @players = Player.all
    # Player.update_all if (Time.now - @players[-1][:updated_at].to_time) / (60 * 60) > 10
  end


  def league_graph
    @general_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/bootstrap-static/").read)
    @current_gw = @general_api["events"].find { |week| week["is_current"] }["id"]
    @league_id = params[:id]
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
    return players
  end

  def players_count
    groups = @all_teams.flatten.group_by(&:itself)
    groups.map { |value, group| [value, group.count] }
  end
end
