class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    @user_info = {
      budget_left: 10.0,
      gameweek: 5,
      rating: 85,
      team_ranking: 1000
    }
    @team_strengths = [] # Fetch player strengths here
    @team_weaknesses = [] # Fetch player weaknesses here
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
