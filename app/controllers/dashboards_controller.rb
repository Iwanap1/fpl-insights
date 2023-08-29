class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    # Logic for fetching user's data, team strengths, and weaknesses will be here
    # You can integrate with the FPL API as per the guide you provided
    # For example:
    @user_info = {
      budget_left: 10.0,
      gameweek: 5,
      rating: 85,
      team_ranking: 1000
    }
    @team_strengths = [] # Fetch player strengths here
    @team_weaknesses = [] # Fetch player weaknesses here
  end
end
