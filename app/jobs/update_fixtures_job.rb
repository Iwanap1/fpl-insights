require "open-uri"
require "json"

class UpdateFixturesJob < ApplicationJob
  queue_as :default

  def perform
    Fixture.update_all
  end
end
