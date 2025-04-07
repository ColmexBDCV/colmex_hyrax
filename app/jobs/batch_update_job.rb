class BatchUpdateJob < ApplicationJob
  queue_as :default

  def perform(batch_ids, work_params_hash, user_key)
    begin
      current_user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Usuario no encontrado: #{user_id}"
      return # Salir temprano del job
    end

    ability = Ability.new(current_user)

    batch_ids.each do |doc_id|
      obj = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: doc_id, use_valkyrie: false)
      merged_params = work_params_hash.merge(admin_set_id: obj.admin_set_id)
      sanitized_params = Forms::BatchEditForm.model_attributes(merged_params)

      # Usar método del módulo
      interpret_visibility_params(obj, sanitized_params, ability)

      obj.attributes = sanitized_params.except(*visibility_params) # Usar método del módulo
      obj.date_modified = Time.current.ctime

      if obj.save
        InheritPermissionsJob.perform_later(obj, use_valkyrie: false)
        VisibilityCopyJob.perform_later(obj)
      end
    rescue => e
      Rails.logger.error "Error actualizando documento #{doc_id}: #{e.message}"
    end
  end
end
