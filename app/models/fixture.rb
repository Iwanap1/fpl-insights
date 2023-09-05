class Fixture < ApplicationRecord
  belongs_to :home_team
  belongs_to :away_team

  def start_time
    self.date
  end

  def self.update_all
    fixture_url = "https://fantasy.premierleague.com/api/fixtures/"
    fixture_info = JSON.parse(URI.open(fixture_url).read)
    Fixture.all.each do |fixture|
      api_fixture = fixture_info.find { |f| f["team_a"] == fixture.away_team_id && f["team_h"] == fixture.home_team_id }
      fixture.date = Date.parse(fixture["kickoff_time"].split("T")[0])
      # Continue here, fixture == db, api_fixture == api


      fixture.save
    end
  end
end
