class Player < ApplicationRecord
  belongs_to :away_team
  belongs_to :home_team

  def general
    return (3 * (self.form / 9) + ( 2 * 17 / self.fixture_difficulty)) / 5
  end
end
