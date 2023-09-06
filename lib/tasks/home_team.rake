namespace :home_team do
  desc "Update all team info"
  task update_all: :environment do
    TeamsJob.perform_later
  end
end
