class UpdateCreateJob < ApplicationJob
  queue_as :default

  def perform(filename, work, update_id=nil)

    parser = ColmexCsvParser.new(file: File.open(filename), work: work, update: true)
    Importer.new(parser: parser, work: work, update: true, update_id: update_id).import
  end
end
