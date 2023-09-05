namespace :fixture do
  desc "TODO"
  task update_all: :environment do
    UpdateFixturesJob.perform_later
  end
end
