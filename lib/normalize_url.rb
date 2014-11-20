module NormalizeUrl
  autoload :VERSION,    "normalize_url/version"
  autoload :Normalizer, "normalize_url/normalizer"

  class InvalidURIError < ArgumentError; end

  extend self

  def process(url, **options)
    Normalizer.new(url.to_s, options).normalize
  end
end
