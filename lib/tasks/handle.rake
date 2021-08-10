namespace :handle do
    desc "Create Handle for every work without one"
    task create: :environment do 
        CreateHandleJob.perform_later()
    end
end