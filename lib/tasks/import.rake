# frozen_string_literal: true

namespace :colmex do
  namespace :import do
    desc 'Run sample import of bepress fixture csv'
    task import_sample_records: :environment do
      parser = ColmexCsvParser.new(file: File.open('test.csv'))

      Importer.new(parser: parser).import
    end

    desc 'Batch import of bepress formatted csv'
    task :bepress_csv, [:filename] => [:environment] do |_task, args|
      parser = ColmexCsvParser.new(file: File.open(args[:filename]))

      Importer.new(parser: parser).import if parser.validate
    end

    desc 'Batch import with specific Type Work'
    task :test, [:filename, :work] => [:environment]  do |_task, args|
      
      parser = ColmexCsvParser.new(file: File.open(args[:filename]), work: args[:work])
      
      Importer.new(parser: parser, work: args[:work]).import # if parser.validate
    end
  end
end
