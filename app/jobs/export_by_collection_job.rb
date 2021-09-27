class ExportByCollectionJob < ApplicationJob
  queue_as :default
  
  def perform(coll)
    ExporterService.by_collection(coll)
  end
end
