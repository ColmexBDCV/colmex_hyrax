class BatchUpdateJob < ApplicationJob
  queue_as :default

  def perform(batch_ids, work_params_hash, user_id)
    # Crear instancia del controlador
    controller = Hyrax::BatchEditsController.new
    controller.request = ActionDispatch::Request.new({})
    controller.response = ActionDispatch::Response.new
    controller.instance_variable_set(:@_params, work: work_params_hash)
    controller.send(:set_current_user, User.find(user_id))

    controller.process_batch_update(batch_ids)
  end
end
