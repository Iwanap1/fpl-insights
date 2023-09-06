namespace :away_team do
  desc "TODO"
  task update_all: :environment do
    AwayTeamUpdateJob.perform_later
  end

end
