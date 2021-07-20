# frozen_string_literal: true

namespace :colmex do
  namespace :import do
    desc 'Batch import with specific Type Work'
    task :create, [:filename, :work, :collection] => [:environment]  do |_task, args|
      
     parser = ColmexCsvParser.new(file: File.open(args[:filename]), work: args[:work])
     
      if parser.validate then
        puts "Import of new objects has started\n\n"

        ImportCreateJob.perform_later(args[:filename], args[:work], args[:collection])
      else
        puts "Invalid CSV"
      end
    end

    desc 'Batch update with specific Type Work & identifier metadata'
    task :update, [:filename, :work] => [:environment]  do |_task, args|

      parser = ColmexCsvParser.new(file: File.open(args[:filename]), work: args[:work])

      if parser.validate then
        puts "Import of an update metadata started\n\n"

        ImportUpdateJob.perform_later(args[:filename], args[:work])
      else
        puts "Invalid CSV"
      end
    end
  end  
  namespace :collection do
    desc 'add works to collection'
    task :add_works, [:filename, :work, :collection] => [:environment]  do |_task, args|

        parser = ColmexCsvParser.new(file: File.open(args[:filename]), work: args[:work] )

        if parser.validate then
            puts "Add works to collection has started\n\n"
            
            AddToCollectionJob.perform_later(args[:filename], args[:work], args[:collection])
        else
            puts "Invalid CSV"
        end
    end
    desc 'remove works from collection'
    task :remove_works, [:filename, :work, :collection] => [:environment]  do |_task, args|

        parser = ColmexCsvParser.new(file: File.open(args[:filename]), work: args[:work] )

        if parser.validate then
            puts "Remove works from collection has started\n\n"

            RemoveFromCollectionJob.perform_later(args[:filename], args[:work], args[:collection])
        else
            puts "Invalid CSV"
        end
    end
  end
end
