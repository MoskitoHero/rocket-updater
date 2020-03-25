namespace :alienor do
  desc "creates all the rooms after import"
  task create_all_rooms: :environment do
    Updater.new('importer', Rails.env['pw']).create_all_rooms
  end

  desc "updates users"
  task update: :environment do
    Updater.new('importer', Rails.env['pw']).update
  end

  desc "Imports users from CSV files"
  task import: :environment do
    Importer.new.import
  end

end
