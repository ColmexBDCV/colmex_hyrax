class FileSetAccessJob < ApplicationJob
  queue_as :default

  def perform(permission, text)
    FileSetAccessService.change_permissions(permission,text)
  end
end
