# frozen_string_literal: true

Rails.application.config.to_prepare do
  fedora = ActiveFedora::Fedora.instance
  connection = Ldp::Client.new(fedora.authorized_connection)

  Valkyrie::StorageAdapter.register(
    Wings::Valkyrie::Storage.new(connection: connection, base_path: fedora.base_path),
    :active_fedora
  )
end
