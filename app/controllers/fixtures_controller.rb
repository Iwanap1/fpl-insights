class FixturesController < ApplicationController

  def index
    @fixtures = Fixture.where(gameweek_number: 4)
  end

end
