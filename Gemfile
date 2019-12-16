source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0.1'

gem 'administrate'
gem 'administrate-field-active_storage'
gem 'administrate-field-jsonb'
gem 'aws-sdk-s3'
gem 'aws-sdk-transcribeservice'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise'
gem 'devise-i18n'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pry-doc'
gem 'pry-rails'
gem 'puma', '~> 4.1'
gem 'rails-i18n'
gem 'slim-rails'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'

# gem 'redis', '~> 4.0'
# gem 'bcrypt', '~> 3.1.7'
# gem 'image_processing', '~> 1.2'


group :development, :test do
  gem 'factory_bot_rails'
  gem 'guard'
  gem 'guard-livereload', require: false
  gem 'guard-rspec'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'rack-livereload'
  gem 'rspec-rails', '~> 4.0.0.beta2'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # gem 'capybara', '>= 2.15'
  # gem 'selenium-webdriver'
  # gem 'webdrivers'
  gem 'webmock'
  gem 'vcr'
end
