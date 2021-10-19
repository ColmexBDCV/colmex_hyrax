class ExportByWorkTypeJob < ApplicationJob
  queue_as :default
  
  def perform(wt,keys)
    ExporterService.by_work_type(wt,keys)
  end
end
