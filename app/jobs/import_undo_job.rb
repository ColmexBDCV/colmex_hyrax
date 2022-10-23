class ImportUndoJob < ApplicationJob
    queue_as :default
  
    def perform(id_import, work, identifiers)
      ImporterService.delete_records_by_identifiers(id_import, work, identifiers)
    end
  end