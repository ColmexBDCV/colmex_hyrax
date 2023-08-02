require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hyrax
  class Application < Rails::Application
    #add actor to work with workers
    
    config.to_prepare  do
      Hyrax::CurationConcern.actor_factory.insert_before(Hyrax::Actors::ModelActor, RecordChangeActor)
      Hyrax::CurationConcern.actor_factory.insert_after(Hyrax::Actors::ModelActor, FixUpdateActor)
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.i18n.default_locale = :en

    config.time_zone = 'Mexico City'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_job.queue_adapter = ENV.fetch('ACTIVE_JOB_QUEUE_ADAPTER', 'inline').to_sym

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end

  end
end
