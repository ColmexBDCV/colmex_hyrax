class ExportCsvJob < ApplicationJob
  queue_as :default

  def perform(import_name, wt, identifiers)
    object_ids = []
    not_found_ids = []

    identifiers.each do |i|
      record = wt.singularize.classify.constantize.where(identifier: i).first
      if record.present?
        object_ids.push(record.id)
      else
        not_found_ids.push(i)
      end
    end

    ExporterService.export(object_ids, nil, import_name, "digital_objects/#{import_name}", not_found_ids) unless object_ids.empty?
  end
end
