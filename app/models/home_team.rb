class HomeTeam < ApplicationRecord
  has_many :players
  has_many :fixtures
end
