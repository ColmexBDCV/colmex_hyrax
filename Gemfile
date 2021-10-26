source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
# gem 'bagit'
gem 'awesome_print'
gem 'dotenv-rails'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma'
#Use mysql as the database for Active Record
gem 'mysql2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0' 
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
gem 'redis'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

#Use i18n-js to translate text in JS
gem 'i18n-js'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'iso-639', git: 'https://github.com/ColmexBDCV/iso-639.git', branch: 'master'
gem 'hydra-role-management'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'blacklight_oai_provider'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'xray-rails'
  #To envolve the variables in you envoriments
  gem 'figaro'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'blacklight_range_limit', '6.3.3'
gem 'blacklight_advanced_search'

gem 'hyrax', '2.9.6'
gem 'darlingtonia',  '3.1.1'
gem 'rack-cors'
gem 'hydra-access-controls'
gem 'hydra-derivatives', '3.6.0'
gem 'streamio-ffmpeg'
group :development, :test do
  gem 'solr_wrapper', '>= 0.3'
end

gem 'rsolr', '>= 1.0'
gem 'jquery-rails'
gem 'jquery-migrate-rails'
gem 'devise'
gem 'devise-guests'
gem 'devise-i18n'
group :development, :test do
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
end

gem 'clipboard-rails'
gem 'pdfjs_viewer-rails'
gem 'riiif', '~> 2.0'
gem "recaptcha"
