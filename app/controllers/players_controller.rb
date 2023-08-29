require "open-uri"
require "json"

class PlayersController < ApplicationController
  def index
    @players = Player.all
    update_data
    # Getting API data for each player and putting into array of hashes
    @ranked = rankings
  end

  def show
  end

  def rankings
    # Returns top 10 transfers in array
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    general_info = JSON.parse(URI.open(general_url).read)
    @ranked = []
    @players.each_with_index do |player, index|
      fixture_difficulty = fixture_difficulty(player.api_id)
      score = player.form / 10 * (1 / fixture_difficulty.to_f)
      @ranked << {
        last_name: player.web_name,
        position: player.position,
        team: player.home_team.short_name,
        score: score,
        form: player.form,
        price: player.price,
        selected: player.selected,
        ict: player.ict,
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

private

def update_data
  general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
  elements = JSON.parse(URI.open(general_url).read)["elements"]
  elements.each do |element|
    player = @players.find { |item| item.api_id == element["id"].to_i }
    player.form = element["form"].to_f
    player.save
  end
end
