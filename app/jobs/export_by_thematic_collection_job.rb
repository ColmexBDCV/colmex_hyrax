class ExportByThematicCollectionJob < ApplicationJob
    queue_as :default
    
    def perform(collkeys)
      ExporterService.by_thematic_collection(coll,keys)
    end
  end