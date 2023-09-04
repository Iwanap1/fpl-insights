namespace :player do
  desc "TODO"
  task update_all: :environment do
    UpdateJob.perform_later
  end
end
