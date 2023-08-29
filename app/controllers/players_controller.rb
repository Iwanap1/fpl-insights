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
    @players.each_with_index do |player, index|
      player_info = general_info["elements"][index]
      fixture_diffculty = 15
      score = player_info["form"].to_f / 10 * (1 / fixture_diffculty.to_f)
      @ranked << {
        last_name: player_info["web_name"],
        position: player.position,
        team: player.home_team.short_name,
        score: score,
        form: player_info["form"],
        price: player_info["now_cost"].to_f / 10,
        selected: player_info["selected_by_percent"].to_f,
        ict: player_info["ict_index"].to_f
      }
    end
    return @ranked.sort_by { |player| player[:score] }.reverse
  end
end
