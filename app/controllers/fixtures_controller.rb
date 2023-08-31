class FixturesController < ApplicationController
  def index
    @general_api = JSON.parse(URI.open("https://fantasy.premierleague.com/api/bootstrap-static/").read)
    @next_gw = @general_api["events"].find { |week| week["is_next"] }["id"]
    @fixtures = Fixture.where(gameweek_number: params[:gameweek] || @next_gw)
  end

end
