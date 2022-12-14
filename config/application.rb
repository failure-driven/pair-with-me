# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

$LOAD_PATH << File.join(__dir__, "../lib")
require "skipping_sass_compressor"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PairWithMe
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Use raw SQL over rails based schema.rb
    config.active_record.schema_format = :sql

    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
    end

    # skip SassC compressor if it fails like when using Adminsitrate with
    # TailwindCSS
    # https://github.com/thoughtbot/administrate/issues/2091#issuecomment-1082742540
    config.assets.css_compressor = SkippingSassCompressor.new

    # configure custom mailer for devise
    config.to_prepare do
      Devise::Mailer.layout "mailer"
    end

    # use sidekiq for active jobs
    config.active_job.queue_adapter = :sidekiq
  end
end
