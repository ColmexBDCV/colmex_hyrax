require 'csv'
require 'fileutils'

class ExportCsvJob < ApplicationJob
  queue_as :default

  def perform(import_name, wt, identifiers, log_entries = nil, batch_date = nil)
    if log_entries.present?
      export_update_log(import_name, log_entries, batch_date)
      return
    end

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

  private

    def export_update_log(sip_name, log_entries, batch_date = nil)
      timestamp = batch_date ? Time.parse(batch_date.to_s).strftime('%Y%m%d_%H%M%S') : Time.current.strftime('%Y%m%d_%H%M%S')
      path = "digital_objects/#{sip_name}"
      safe_sip_name = sip_name.to_s.gsub(/[^0-9A-Za-z_\-]/, '_')
      filename = "log_#{safe_sip_name}_#{timestamp}.csv"

      FileUtils.mkdir_p(path) unless File.directory?(path)

      # Recopilar todos los campos que cambiaron en cualquier registro del lote
      changed_fields = log_entries.flat_map do |entry|
        changes = entry.is_a?(Hash) ? (entry['changes'] || entry[:changes]) : nil
        next [] unless changes.is_a?(Hash)
        changes.keys.map(&:to_s)
      end.uniq.sort

      # Construir headers dinámicos: identifier, estado, y pares antes/después por campo
      field_headers = changed_fields.flat_map { |f| ["#{f}_antes", "#{f}_despues"] }
      headers = ['identifier', 'estado'] + field_headers

      CSV.open("#{path}/#{filename}", 'wb', headers: headers, write_headers: true, force_quotes: true) do |csv|
        log_entries.each do |entry|
          next unless entry.is_a?(Hash)
          identifier = entry['identifier'] || entry[:identifier]
          status     = entry['status']     || entry[:status]
          changes    = entry['changes']    || entry[:changes]

          row = [identifier, status]
          changed_fields.each do |field|
            change_entry = if changes.is_a?(Hash)
              changes[field] || changes[field.to_sym]
            end

            if change_entry.present?
              before_val, after_val = extract_change_pair(change_entry)
              row << (before_val.is_a?(Array) ? before_val.join(' | ') : before_val.to_s)
              row << (after_val.is_a?(Array)  ? after_val.join(' | ')  : after_val.to_s)
            else
              row << ''
              row << ''
            end
          end
          csv << row
        end
      end
    end

    def extract_change_pair(change_entry)
      if change_entry.is_a?(Hash)
        before_val = change_entry['before'] || change_entry[:before]
        after_val  = change_entry['after']  || change_entry[:after]
        [before_val, after_val]
      elsif change_entry.is_a?(Array)
        [change_entry[0], change_entry[1]]
      else
        [nil, nil]
      end
    end
end
