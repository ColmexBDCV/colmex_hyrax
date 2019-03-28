# frozen_string_literal: true

namespace :colmex do
  namespace :import do
    desc 'Batch import with specific Type Work'
    task :create, [:filename, :work, :collection] => [:environment]  do |_task, args|
      
      parser = ColmexCsvParser.new(file: File.open(args[:filename]), work: args[:work])
      
      Importer.new(parser: parser, work: args[:work], collection: args[:collection]).import if parser.validate
    end

    desc 'Batch update with specific Type Work & identifier metadata'
    task :update, [:filename, :work] => [:environment]  do |_task, args|
      
      parser = ColmexCsvParser.new(file: File.open(args[:filename]), work: args[:work], update: true)
      
      Importer.new(parser: parser, work: args[:work], update: true).import if parser.validate
    end
  end
end
