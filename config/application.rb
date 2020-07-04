require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SampleApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0


    # File: config/application.rb
    config.exceptions_app = self.routes


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    ENV['titlepage'] = 'MG Suivi'
    ENV['MJ_APIKEY_PUBLIC'] = '6532da700924bb9f1c446083039c4566'
    ENV['MJ_APIKEY_PRIVATE'] = '77eaf825c21d0015e6cda0fbaed1d6c7'
  end
end
