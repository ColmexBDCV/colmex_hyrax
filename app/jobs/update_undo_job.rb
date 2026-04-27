class UpdateUndoJob < ApplicationJob
    queue_as :default
  
    def perform(id_update)
      update = Update.find(id_update)
      update.status = "Cancelado"
      update.save
    end
  end