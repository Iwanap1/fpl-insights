require "open-uri"
require "json"

class PlayersController < ApplicationController
  def index
    @players = Player.all
    # Getting API data for each player and putting into array of hashes
    @live_data = []
    @ranked = ranking
  end

  def ranking
    # Returns top 10 transfers in array
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    general_info = JSON.parse(URI.open(general_url).read)
    @ranked = []
    @top = general_info["elements"]
    @players.each_with_index do |player, index|
      player_info = general_info["elements"][index]
      fixture_difficulty = fixture_difficulty(player.api_id)
      score = player_info["form"].to_f / 10 * (1 / fixture_difficulty.to_f)
      @ranked << {
        last_name: player_info["web_name"],
        position: player.position,
        team: player.home_team.short_name,
        score: score,
        form: player_info["form"],
        price: player_info["now_cost"].to_f / 10,
        selected: player_info["selected_by_percent"].to_f,
        ict: player_info["ict_index"].to_f,
        fixture_difficulty: fixture_difficulty
      }
    end
    return @ranked.sort_by { |p| p[:score] }.reverse
  end

  def fixture_difficulty(id)
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

  def logical_searches
    # return array of players to call api for fixture difficulty
  end
end
