require "set"
require "addressable/uri"

module NormalizeUrl
  class Normalizer
    attr_reader :uri, :options

    TRACKING_QUERY_PARAMS = %w[
      utm_source
      utm_medium
      utm_term
      utm_content
      utm_campaign
      sms_ss
      awesm
      xtor
      PHPSESSID
    ].to_set.freeze

    def initialize(original_uri, options={})
      @uri = Addressable::URI.parse(original_uri).normalize
      @options = options
      fail_uri "only absolute URLs can be normalized" unless uri.absolute?
      fail_uri "only HTTP/HTTPS URLs can be normalized" unless uri.scheme =~ /https?/
    rescue Addressable::URI::InvalidURIError
      fail_uri "#{original_uri.inspect} is not a URL"
    end

    def normalize
      process :remove_trailing_slash
      process :remove_repeating_slashes
      process :remove_hash
      process :remove_tracking
      process :remove_params
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

    def process_remove_tracking
      remove_params TRACKING_QUERY_PARAMS
    end

    def process_remove_params
      remove_params Array(@options.fetch(:remove_params, nil)).map(&:to_s)
    end

    def remove_params(params)
      return unless uri.query_values
      original = uri.query_values
      cleaned = original.reject{ |key, _| params.include?(key) }

      if cleaned.empty?
        uri.query_values = nil
      elsif cleaned != original
        uri.query_values = cleaned
      end
    end

    def fail_uri(message)
      fail ArgumentError, message
    end
  end
end
