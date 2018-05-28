# frozen_string_literal: true

namespace :colmex do
  namespace :import do
    desc 'Batch import with specific Type Work'
    task :test, [:filename, :work] => [:environment]  do |_task, args|
      
      parser = ColmexCsvParser.new(file: File.open(args[:filename]), work: args[:work])
      
      Importer.new(parser: parser, work: args[:work]).import if parser.validate
    end
  end
end
