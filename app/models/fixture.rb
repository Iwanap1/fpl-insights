class Fixture < ApplicationRecord
  belongs_to :home_team
  belongs_to :away_team

  def start_time
    self.date
  end

  def self.update_all
    fixture_url = "https://fantasy.premierleague.com/api/fixtures/"
    fixture_info = JSON.parse(URI.open(fixture_url).read)
  end
end
