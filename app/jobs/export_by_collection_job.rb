class ExportByCollectionJob < ApplicationJob
  queue_as :default
  
  def perform(coll,keys)
    ExporterService.by_collection(coll, keys)
  end
end
