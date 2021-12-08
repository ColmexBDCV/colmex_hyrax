class ExportByThematicCollectionJob < ApplicationJob
    queue_as :default
    
    def perform(keys)
      ExporterService.by_thematic_collection(coll,keys)
    end
  end