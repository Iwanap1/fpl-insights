class Fixture < ApplicationRecord
  belongs_to :home_team
  belongs_to :away_team

  def start_time
    self.date
  end
end
