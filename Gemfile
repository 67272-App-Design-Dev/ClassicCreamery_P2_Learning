source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '8.1.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails', '3.5.2'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '2.8.0'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '7.1.0'

# Use SCSS for stylesheets
gem 'dartsass-rails', '0.5.1'
gem 'sassc-rails', '2.1.2'  # For Sprockets SCSS processing
gem 'terser', '1.2.6'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails', '2.0.20'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
# gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder', '2.14.1'

# Use Redis adapter to run Action Cable in production
gem 'redis', '5.4.1'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '3.1.20'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', '2.0.6', platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.19.0', require: false

# For serializing models to json for the API
gem 'jsonapi-serializer'

# Use fast_jsonapi for fast serialization
# gem 'fast_jsonapi', '1.5'

# Adding React gems
gem 'react-rails', '3.2.1'
gem 'shakapacker', '7.2.3'

# Other gems
gem 'validates_timeliness', '8.0.0'
gem 'time_date_helpers', '0.0.4'
gem 'cancancan', '3.6.1'
gem 'simple_form', '5.4.0'
gem 'will_paginate', '4.0.1'
gem 'jquery-rails', '4.6.1'
gem 'jquery-ui-rails', '8.0.0'

# Locking for autograder
gem 'date', '3.5.0'
gem 'diff-lcs', '1.6.2'
gem 'docile', '1.4.1'
gem 'drb', '2.2.3'
gem 'erb', '6.0.0'
gem 'erubi', '1.13.1'
gem 'execjs', '2.10.0'
gem 'ffi', '1.17.2'
gem 'i18n', '1.14.7'
gem 'io-console', '0.8.1'
gem 'irb', '1.15.3'
gem 'logger', '1.7.0'
gem 'loofah', '2.24.1'
gem 'nio4r', '2.7.5'
gem 'nokogiri', '1.18.10'
gem 'racc', '1.8.1'
gem 'rack', '3.2.4'
gem 'rack-proxy', '0.7.7'
gem 'rack-session', '2.1.1'
gem 'rack-test', '2.2.0'
gem 'rackup', '2.2.1'
gem 'rails-html-sanitizer', '1.6.2'
gem 'rake', '13.3.1'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', '1.11.0', platforms: %i[ mri mingw x64_mingw ]
  gem 'hirber', '0.8.9'

  gem 'factory_bot_rails', '6.5.1'
  gem 'rails-controller-testing', '1.0.5'
  gem 'shoulda-context', '2.0.0'
  gem 'shoulda-matchers', '7.0.1'
  gem 'minitest', '5.26.2'
  gem 'minitest-rails','8.1.0'
  gem 'minitest-reporters', '1.7.1'
  gem 'simplecov', '0.22.0'

  gem 'cucumber', '10.1.1'
  gem 'cucumber-rails', '4.0.0', require: false
  gem 'database_cleaner-active_record', '2.2.2'
  gem 'database_cleaner-core', '2.0.1'
  gem 'launchy', '3.1.1'

  gem 'faker', '3.5.2'
  gem 'rails-dom-testing', '2.3.0'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console', '4.2.1'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem 'rack-mini-profiler'

end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara', '3.40.0'
  gem 'selenium-webdriver', '4.10.0'
  gem 'webdrivers', '5.3.1'
end
