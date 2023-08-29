require "open-uri"
require "json"

class PlayersController < ApplicationController
  def index
    @players = Player.all
    # Getting API data for each player and putting into array of hashes
    @live_data = []
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    general_info = JSON.parse(URI.open(general_url).read)
    @players.each_with_index do |player, index|
      player_info = general_info["elements"][index]
      @live_data << {
        form: player_info["form"],
        price: player_info["now_cost"].to_f / 10,
        selected: player_info["selected_by_percent"].to_f,
        ict: player_info["ict_index"].to_f
      }
    end
  end
end
