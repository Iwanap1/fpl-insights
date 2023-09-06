require 'open-uri'
require 'json'


class Player < ApplicationRecord
  belongs_to :away_team
  belongs_to :home_team
  validates :api_id, uniqueness: true

  def general_score(n)
    form_weight = 7
    fixture_weight = n.zero? ? 0 : 6
    fixture_calc = n.zero? ? 0 : fixture_weight * calc_fixture_two(n).to_f
    case self.position
    when "GKP"
      goal_conceded_weight = 4
      goal_involvement_weight = 0
      penalty_order_weight = 0
      ict_weight = 0
    when "DEF"
      goal_conceded_weight = 2.2
      goal_involvement_weight = 1.2
      penalty_order_weight = 0.2
      ict_weight = 0.4
    when "MID"
      goal_conceded_weight = 0.2
      goal_involvement_weight = 2.1
      penalty_order_weight = 0.6
      ict_weight = 1
    else
      goal_conceded_weight = 0
      goal_involvement_weight = 2.5
      penalty_order_weight = 1
      ict_weight = 0.5
    end
    sum_of_weights = form_weight + fixture_weight + goal_conceded_weight + goal_involvement_weight + penalty_order_weight + ict_weight

    if self.minutes < 90
      sum = 0
    else
      sum = (
        (form_weight * (self.form > 10 ? 1 : (self.form / 10))) +
        fixture_calc +
        (goal_conceded_weight * goal_concede_calc) +
        (goal_involvement_weight * goal_involvement_calc) +
        (ict_weight * (self.ict / 50)) +
        (penalty_order_weight * (1 / self.penalty_order))
      )
    end
    return (sum) / sum_of_weights
  end

  def calc_fixture
    case fixture_difficulty
    when (1..10) then return 1
    when (11..12) then return 0.8
    when (13..14) then return 0.6
    when (15..16) then return 0.4
    when (17..18) then return 0.2
    else
      return 0
    end
  end

  def full_position
    case position
    when "FOR" then return "forward"
    when "MID" then return "midfield"
    when "DEF" then return "defender"
    when "GKP" then return "goalkeeper"
    end
  end

  def goal_concede_calc
    sorted = Player.all.reject { |p| p.expected_goals_conceded == 0 }.sort_by { |player| player.expected_goals_conceded }
    if sorted.uniq.include?(self) && self.minutes > 90
      result = (sorted.count - sorted.index(self).to_f) / sorted.count
    else
      result = 0
    end
    return result
  end

  def goal_involvement_calc
    sorted = Player.all.reject { |p| p.expected_goal_involvements.zero? }.sort_by { |player| player.expected_goal_involvements }.reverse
    if sorted.uniq.include?(self) && self.minutes > 90
      result = (sorted.count - sorted.index(self).to_f) / sorted.count
    else
      result = 0
    end
    return result
  end

  def fixtures
    data = JSON.parse(URI.open("https://fantasy.premierleague.com/api/element-summary/#{self.api_id}/").read)
    fixtures = data["fixtures"]
    difficulties = []
    fixtures.first(5).each do |fixture|
      difficulties << fixture["difficulty"].to_i
    end
    if data["history_past"].empty?
      previous_points = 0
    else
      previous_points = data["history_past"].last["total_points"]
    end
    return {
      fixture_difficulty: difficulties.sum,
      previous_points: previous_points
    }
  end

  def self.update_all
    general_url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    elements = JSON.parse(URI.open(general_url).read)["elements"]
    elements.each do |element|
      if Player.all.find { |player| player.api_id == element["id"] }
        player = Player.all.find { |p| p.api_id == element["id"] }
        player.fixture_difficulty = player.fixtures[:fixture_difficulty]
        player.fixtures_array = player.fixture_diff_array
        player.form = element["form"].to_f
        player.price = element["now_cost"].to_f / 10
        player.ict = element["ict_index"].to_f
        player.selected = element["selected_by_percent"]
        player.updated_at = Time.now
        player.chance = element["chance_of_playing_next_round"].to_f / 100
        player.expected_goal_involvements = element["expected_goal_involvements_per_90"].to_f
        player.expected_goals_conceded = element["expected_goals_conceded_per_90"].to_f
        player.transfers_in = element["transfers_in_event"]
        player.penalty_order = element["penalties_order"].nil? ? 5 : element["penalties_order"]
        player.free_kick_order = element["direct_freekicks_order"].nil? ? 5 : element["direct_freekicks_order"]
        player.minutes = element["minutes"]
        player.goals = element["goals_scored"]
        player.assists = element["assists"]
        player.total = element["total_points"]
        player.save
      else
        new = Player.new
        new.first_name = element["first_name"]
        new.last_name = element["second_name"]
        if element["element_type"] == 1
          new.position = "GKP"
        elsif element["element_type"] == 2
          new.position = "DEF"
        elsif element["element_type"] == 3
          new.position = "MID"
        else
          new.position = "FOR"
        end
        new.away_team_id = element["team"]
        new.home_team_id = element["team"]
        new.api_id = element["id"]
        new.form = element["form"]
        new.price = element["now_cost"].to_f / 10
        new.web_name = element["web_name"]
        new.ict = element["ict_index"].to_f
        new.selected = element["selected_by_percent"]
        new.chance = element["chance_of_playing_next_round"].to_f / 100
        new.expected_goal_involvements = element["expected_goal_involvements_per_90"].to_f
        new.expected_goals_conceded = element["expected_goal_conceded_per_90"].to_f
        new.transfers_in = element["transfers_in_event"]
        new.penalty_order = element["penalties_order"].nil? ? 5 : element["penalties_order"]
        new.free_kick_order = element["direct_freekicks_order"].nil? ? 5 : element["direct_freekicks_order"]
        new.minutes = element["minutes"]
        new.goals = element["goals_scored"]
        new.assists = element["assists"]
        new.total = element["total_points"]
        new.save
        new.previous_points = new.fixtures[:previous_points]
        new.fixture_difficulty = new.fixtures[:fixture_difficulty]
        new.fixtures_array = new.fixture_diff_array
        new.save
      end
    end
  end

  def attributes(current_gw)
    attributes = []
    attributes << "Top 10 This Season" if Player.all.sort_by { |p| p.total }.reverse.index(self) < 10
    attributes << "Top 10 Last Season" if Player.all.sort_by { |p| p.previous_points }.reverse.index(self) < 10
    attributes << "Penalty Taker" if self.penalty_order == 1
    attributes << "Free Kick Taker" if self.free_kick_order == 1
    attributes << "Regular Game Time" if (self.minutes / current_gw) > 80
    return attributes
  end


  def fixtures_variable(n)
    upcoming_fixtures = Fixture.all.select { |f| f.home_team == self.home_team || f.away_team == self.away_team }.reject { |f| f.finished }.first(n)
    difficulty_score = 0
    difficulty_attack = 0
    difficulty_defence = 0

    upcoming_fixtures.each do |f|
      if f.home_team == self.home_team
        difficulty_score += f.away_team.difficulty
        difficulty_attack += f.away_team.strength_defence
        difficulty_defence += f.away_team.strength_attack
      else
        difficulty_score += f.home_team.difficulty
        difficulty_attack += f.home_team.strength_defence
        difficulty_defence += f.home_team.strength_attack
      end
    end
    return {
      difficulty_score: difficulty_score,
      difficulty_attackers: difficulty_attack,
      difficulty_defenders: difficulty_defence
    }
  end

  def fixture_diff_array
    array = [0]
    (1..10).each do |n|
      if self.position == "DEF" || self.position == "GKP"
        array << self.fixtures_variable(n)[:difficulty_defenders]
      else
        array << self.fixtures_variable(n)[:difficulty_attackers]
      end
    end
    return array.map { |e| e.to_s }.join("X")
  end

  def calc_fixture_two(n)
    all = Player.all.map { |p| p.fixtures_array.split("X")[n].to_f }.uniq.sort
    rank = all.index(self.fixtures_array.split("X")[n].to_f)
    return (all.count - rank.to_f) / (all.count - 1)
  end
end
