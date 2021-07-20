class AddToCollectionJob < ApplicationJob
    queue_as :default

    def perform(filename, work, collection)

        parser = ColmexCsvParser.new(file: File.open(filename), work: work)
        Importer.new(parser: parser, work: work, collection: collection).to_collection_add
    end
end