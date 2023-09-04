require "open-uri"
require "json"

class UpdateJob < ApplicationJob
  queue_as :default

  def perform
    Player.update_all
  end
end
