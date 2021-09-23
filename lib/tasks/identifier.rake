namespace :conacyt do
  desc "Get author identifier from conacyt api"
  task identifier: :environment do  
    IdentifierConacytJob.perform_later()
  end
end
