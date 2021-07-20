class RemoveFromCollectionJob < ApplicationJob
    queue_as :default

    def perform(filename, work, collection)

        parser = ColmexCsvParser.new(file: File.open(filename), work: work)
        Importer.new(parser: parser, work: work, collection: collection).from_collection_remove
    end
end