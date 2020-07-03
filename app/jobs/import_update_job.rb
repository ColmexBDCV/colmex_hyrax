class ImportUpdateJob < ApplicationJob
  queue_as :default

  def perform(filename, work)

    parser = ColmexCsvParser.new(file: File.open(filename), work: work)
    Importer.new(parser: parser, work: work, update: true).import
  end
end
