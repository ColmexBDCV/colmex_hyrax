class ExportByFieldJob < ApplicationJob
  queue_as :default
  
  def perform(value, key,fields)
    ExporterService.by_field(value, key,fields)
  end
end
