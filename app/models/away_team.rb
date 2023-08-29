class AwayTeam < ApplicationRecord
  has_many :players
  has_many :fixtures
end
