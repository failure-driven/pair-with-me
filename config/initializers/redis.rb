# frozen_string_literal: true

# NOTE: not sure if this is necessary? also We seem to be hitting the
# pay-per/request redis api at an alarming rate, not sure if I need this or
# simply the setting in sidekiq.rb
# $redis = Redis.new(url: ENV.fetch("UPSTASH_REDIS_URL", "redis://127.0.0.1:6379"))