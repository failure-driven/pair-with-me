# frozen_string_literal: true

class SkippingSassCompressor
  def compress(string)
    options = {syntax: :scss, cache: false, read_cache: false, style: :compressed}
    begin
      Sprockets::Autoload::SassC::Engine.new(string, options).render
    rescue => e
      Rails.logger.debug { "Could not compress '#{string[0..65]}'...: #{e.message}, skipping compression" }
      string
    end
  end
end
