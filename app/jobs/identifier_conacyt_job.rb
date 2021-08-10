class IdentifierConacytJob < ApplicationJob
  queue_as :default

  def perform(work)
    IdentifierService.work(work)
  end
end
