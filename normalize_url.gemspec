require_relative "lib/normalize_url/version"

Gem::Specification.new do |spec|
  spec.name         = "normalize_url"
  spec.version      = NormalizeUrl::VERSION
  spec.authors      = ["Pavel Pravosud"]
  spec.email        = ["pavel@pravosud.com"]
  spec.summary      = "Normalizing URLs like a Boss"
  spec.homepage     = "https://github.com/rwz/normalize_url"
  spec.license      = "MIT"
  spec.files        = Dir["README.md", "LICENSE.txt", "lib/**/*"]
  spec.require_path = "lib"

  spec.required_ruby_version = "~> 2.0"
  spec.add_dependency "addressable", "~> 2.3"
end
