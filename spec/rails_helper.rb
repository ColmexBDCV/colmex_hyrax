# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration[5.2].maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

require 'webmock/rspec'
WebMock.allow_net_connect!

RSpec.configure do |config|

  config.before(:each) do
    stub_request(:get, "http://catalogs.repositorionacionalcti.mx/webresources/areacono")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Faraday v0.17.6'
        })
      .to_return(status: 200, body: [
        {"cveArea":"2","descripcion":"BIOLOGÍA Y QUÍMICA","description":"BIOLOGÍA Y QUÍMICA","idArea":2},
        {"cveArea":"6","descripcion":"CIENCIAS AGROPECUARIAS Y BIOTECNOLOGÍA","description":"CIENCIAS AGROPECUARIAS Y BIOTECNOLOGÍA","idArea":6},
        {"cveArea":"1","descripcion":"CIENCIAS FÍSICO MATEMÁTICAS Y CIENCIAS DE LA TIERRA","description":"CIENCIAS FÍSICO MATEMÁTICAS Y CIENCIAS DE LA TIERRA","idArea":1},
        {"cveArea":"5","descripcion":"CIENCIAS SOCIALES","description":"CIENCIAS SOCIALES","idArea":5},
        {"cveArea":"4","descripcion":"HUMANIDADES Y CIENCIAS DE LA CONDUCTA","description":"HUMANIDADES Y CIENCIAS DE LA CONDUCTA","idArea":4},
        {"cveArea":"7","descripcion":"INGENIERÍA Y TECNOLOGÍA","description":"INGENIERÍA Y TECNOLOGÍA","idArea":7},
        {"cveArea":"3","descripcion":"MEDICINA Y CIENCIAS DE LA SALUD","description":"MEDICINA Y CIENCIAS DE LA SALUD","idArea":3}
      ].to_json, headers: {})
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.before(:each, type: :feature) do
    # Este bloque se ejecutará solo antes de las pruebas de tipo :feature
    minter_state = MinterState.find_by(namespace: "default")
    if minter_state
      if minter_state.seq % 2 == 0
        minter_state.seq += 1 
      else
        minter_state.seq -= 1
      end
      minter_state.save!
    end
  end
end
