class IdentifierConacytJob < ApplicationJob
  queue_as :default

  def perform()
    IdentifierService.for_all()
  end
end
