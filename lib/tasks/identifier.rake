namespace :conacyt do
  desc "Get author identifier from conacyt api"
  task :identifier, [:work] => [:environment]  do |_task, args|
    IdentifierConacytJob.perform_later(args[:work])
  end
end
