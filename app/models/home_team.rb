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
end
