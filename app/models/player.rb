class Player < ApplicationRecord
  belongs_to :away_team
  belongs_to :home_team

  def general_score
    form_weight = 9
    fixture_weight = 5

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

    if self.expected_goals_conceded.to_i.zero? || self.minutes < 90
      sum = 0
    else
      sum = (
        (form_weight * (self.form / 8)) +
        (fixture_weight * (13.5 / self.fixture_difficulty)) +
        (goal_conceded_weight * (1 / (self.expected_goals_conceded + 0.01))) +
        (goal_involvement_weight * (self.expected_goal_involvements + 0.01)) +
        (ict_weight * (self.ict / 38.9)) +
        (penalty_order_weight * (1 / self.penalty_order))
      )
    end
    return (sum) / sum_of_weights
  end
end
