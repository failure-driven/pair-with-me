# frozen_string_literal: true

require "sidekiq"
require "sidekiq/api"

Rails.configuration.to_prepare do
  connection_url = ENV.fetch("UPSTASH_REDIS_URL", "redis://127.0.0.1:6379")

  Sidekiq.configure_client do |config|
    config.redis = {url: connection_url}
  end

  Sidekiq.configure_server do |config|
    config.redis = {url: connection_url}
  end
end
