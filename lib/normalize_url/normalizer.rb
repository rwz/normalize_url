require "addressable/uri"

module NormalizeUrl
  class Normalizer
    attr_reader :uri, :options

    def initialize(original_uri, options={})
      @uri = Addressable::URI.parse(original_uri).normalize
      @options = options
    end

    def normalize
      process :remove_trailing_slash
      process :remove_repeating_slashes
      process :remove_hash
      process :sort_query
      uri.to_s
    end

    private

    def process(step)
      send "process_#{step}" if process?(step)
    end

    def process?(step)
      @options.fetch(step, true)
    end

    def process_remove_trailing_slash
      uri.path = uri.path.chomp(?/) unless uri.path == ?/
    end

    def process_sort_query
      uri.query = uri.query.split(?&).sort.join(?&) if uri.query
    end

    def process_remove_hash
      uri.fragment = nil
    end

    def process_remove_repeating_slashes
      uri.path = uri.path.squeeze(?/) if uri.host
    end
  end
end
