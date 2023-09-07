class PlayerFixturesJob < ApplicationJob
  queue_as :default

  def perform
    Player.update_column
  end
end
