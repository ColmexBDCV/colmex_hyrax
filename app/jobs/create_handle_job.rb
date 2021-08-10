class CreateHandleJob < ApplicationJob
  queue_as :default
  
  def perform()
    HandleService.assing_handle_for_all
  end
end