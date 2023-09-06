class AwayTeam < ApplicationRecord
  has_many :players
  has_many :fixtures

  def fixture_diff(n)
    away_fixtures = self.fixtures.reject { |f| f.finished }.first(n)
    return {
      difficulty_score: away_fixtures.sum { |f| f.away_team.difficulty },
      difficulty_attack: away_fixtures.sum { |f| f.away_team.strength_attack },
      difficulty_defence: away_fixtures.sum { |f| f.away_team.strength_defence },
      difficulty_overall: away_fixtures.sum { |f| f.away_team.strength_overall }
    }
  end
end
