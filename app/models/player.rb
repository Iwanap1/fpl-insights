class Player < ApplicationRecord
  belongs_to :away_team
  belongs_to :home_team

  def general_score
    form_weight = 6
    fixture_weight = 4
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
        (form_weight * (form > 10 ? 1 : (form / 10))) +
        (fixture_weight * calc_fixture) +
        (goal_conceded_weight * (1 / (self.expected_goals_conceded + 0.01))) +
        (goal_involvement_weight * (self.expected_goal_involvements + 0.01)) +
        (ict_weight * (self.ict / 38.9)) +
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
end
