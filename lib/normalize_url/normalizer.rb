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
      process_query
      uri.to_s
    end

    private

    def process(step)
      send "process_#{step}" if process?(step)
    end

    def process_query
      query_values = uri.query_values
      return if query_values.nil?

      query_values = remove_params(query_values, TRACKING_QUERY_PARAMS) if process?(:remove_tracking)
      query_values = remove_params(query_values, params_to_remove) if process?(:remove_params)
      query_values = query_values.to_a unless process?(:sort_query)

      uri.query_values = query_values.empty? ? nil : query_values
    end

    def process?(step)
      options.fetch(step, true)
    end

    def process_remove_trailing_slash
      uri.path = uri.path.chomp(?/) unless uri.path == ?/
    end

    def process_remove_hash
      uri.fragment = nil
    end

    def process_remove_repeating_slashes
      uri.path = uri.path.squeeze(?/) if uri.host
    end

    def remove_params(query_values, params)
      query_values.reject{ |key, _| params.include?(key) }
    end

    def fail_uri(message)
      fail InvalidURIError, message
    end

    def params_to_remove
      Array(options.fetch(:remove_params, nil)).map(&:to_s)
    end
  end
end
