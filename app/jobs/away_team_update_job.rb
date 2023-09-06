require "open-uri"
require "json"


class AwayTeamUpdateJob < ApplicationJob
  queue_as :default

  def perform
    AwayTeam.update_all
  end
end
