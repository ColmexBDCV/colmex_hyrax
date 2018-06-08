namespace :sidekiq do
  desc "Clear"
  task flush: :environment do
	Sidekiq.redis { |conn| conn.flushdb }	
  end
end
