class ExportByWorkTypeJob < ApplicationJob
  queue_as :default
  
  def perform(wt)
    ExporterService.by_work_type(wt)
  end
end
