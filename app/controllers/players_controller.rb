require "open-uri"
require "json"

class PlayersController < ApplicationController
  def index
    @players = Player.all
    update_data if needs_updating?
    @players = Player.all
    # Getting API data for each player and putting into array of hashes
    @filtered = @players.select { |p| p.position == params[:position] || params[:position] == "all" }.select { |p| p.price <= params[:price].to_f || params[:price] == "all"}
    if params[:position] && params[:price]
      @ranked = @filtered.sort_by { |p| p.general_score }.reverse
    else
      @ranked = @players.sort_by { |p| p.general_score }.reverse
    end
  end

  def show
  end

  def fixtures(id)
    # Currently getting data from 685 APIs so very slow
    # Need to only search logical player APIs
    url = "https://fantasy.premierleague.com/api/element-summary/#{id}/"
    fixtures = JSON.parse(URI.open(url).read)["fixtures"]
    difficulties = []
    fixtures.first(5).each do |fixture|
      difficulties << fixture["difficulty"].to_i
    end
    return difficulties.sum
  end

  def update_data
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    elements = JSON.parse(URI.open(general_url).read)["elements"]
    elements.each do |element|
      player = @players.find { |item| item.api_id == element["id"].to_i }
      player.form = element["form"].to_f
      player.price = element["now_cost"].to_f / 10
      player.web_name = element["web_name"]
      player.ict = element["ict_index"].to_f
      player.selected = element["selected_by_percent"]
      player.updated_at = Time.now
      player.fixture_difficulty = fixtures(player.api_id)
      player.chance = element["chance_of_playing_next_round"].to_f / 100
      player.expected_goal_involvements = element["expected_goal_involvements_per_90"].to_f
      player.expected_goals_conceded = element["expected_goals_conceded_per_90"].to_f
      player.transfers_in = element["transfers_in_event"]
      player.penalty_order = element["penalty_order"].nil? ? 5 : element["penalty_order"]
      player.minutes = element["minutes"]
      player.save
    end
  end

  private

  # Updates Player table every 8 hours but should change to whenever GW is done
  def needs_updating?
    (Time.now - @players[0][:updated_at].to_time) / (60 * 60) > 0
  end
end
