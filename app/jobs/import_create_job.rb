class ImportCreateJob < ApplicationJob
  queue_as :default

  def perform(filename, work, collection = nil)

    parser = ColmexCsvParser.new(file: File.open(filename), work: work)
    Importer.new(parser: parser, work: work, collection: collection).import
  end
end
