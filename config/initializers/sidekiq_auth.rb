require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
 [user, password] == ["admin", ENV['SIDEKIQ_PASS'] || "admin"]
end
