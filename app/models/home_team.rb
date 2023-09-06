require "open-uri"
require "json"

class HomeTeam < ApplicationRecord
  has_many :players
  has_many :fixtures


  def fixture_diff(n)
    home_fixtures = self.fixtures.reject { |f| f.finished }.first(n)
    return {
      difficulty_score: home_fixtures.sum { |f| f.away_team.difficulty },
      difficulty_attack: home_fixtures.sum { |f| f.away_team.strength_attack },
      difficulty_defence: home_fixtures.sum { |f| f.away_team.strength_defence },
      difficulty_overall: home_fixtures.sum { |f| f.away_team.strength_overall }
    }
  end

  def self.update_all
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    team_info = JSON.parse(URI.open(general_url).read)["teams"]
    @all_teams = HomeTeam.all
    team_info.each do |team|
      update = @all_teams.find { |t| t.id == team["id"] }
      update.strength_overall = team["strength_overall_home"]
      update.strength_attack = team["strength_attack_home"]
      update.strength_defence = team["strength_defence_home"]
      update.updated_at = Time.now
      update.save
    end
  end
end
