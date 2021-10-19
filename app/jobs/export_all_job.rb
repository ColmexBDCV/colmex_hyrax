class ExportAllJob < ApplicationJob
    queue_as :default
    
    def perform(keys)
      ExporterService.all(keys)
    end
  end