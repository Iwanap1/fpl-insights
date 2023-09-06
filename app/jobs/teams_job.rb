require "open-uri"
require "json"

class TeamsJob < ApplicationJob
  queue_as :default

  def perform
    HomeTeam.update_all
  end
end
