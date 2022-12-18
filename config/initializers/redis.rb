# frozen_string_literal: true

$redis = Redis.new(url: ENV.fetch("UPSTASH_REDIS_URL", "redis://127.0.0.1:6379"))