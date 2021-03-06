# NormalizeUrl
[![Gem Version](https://img.shields.io/gem/v/normalize_url.svg)](https://rubygems.org/gems/normalize_url)
[![Build Status](https://img.shields.io/travis/rwz/normalize_url.svg)](http://travis-ci.org/rwz/normalize_url)
[![Code Climate](https://img.shields.io/codeclimate/github/rwz/normalize_url.svg)](https://codeclimate.com/github/rwz/normalize_url)

This gem can normalize HTTP(S) URLs by applying a certain set of
transformations. After normalization, two different URLs that point to the same
resource should look exactly the same.

For example:

- `http://example.com/products?product_id=123`
- `HTTP://EXAMPLE.COM/products/?product_id=123`
- `http://example.com/products/?product_id=123`
- `http://example.com/foo/../products?product_id=123`
- `http://example.com/products?product_id=123#comments-section`
- `http://example.com//products/?product_id=123`
- `http://example.com/products/?product_id=123&`
- `http://example.com/products?utm_source=whatever&product_id=123&utm_medium=twitter&utm_campaign=blah`

will all become `http://example.com/products?product_id=123` after normalization.

Some of the transformations are potentially dangerous, since not all webservers
comform to standards and some of them are just plain weird. So there is no
guarantee that the URL will still work.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "normalize_url"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install normalize_url

## Usage

```ruby
NormalizeUrl.process("http://example.com/products/?foo=bar&baz") # => "http://example.com/products?baz&foo=bar"
```

Some tranformations could be skipped by demand. All you need is to pass its
name as a optional value to `normalize` method:

```ruby
NormalizeUrl.process("http://example.com/foo/") # => "http://example.com/foo"
NormalizeUrl.process("http://example.com/foo/", remove_trailing_slash: false) # => "http://example.com/foo/"
```

## Transformations

- Remove trailing slash. Option `:remove_trailing_slash`.

    Example:

    `http://example.com/products/` -> `http://example.com/products`

- Remove repeating slashes. Option `:remove_repeating_slashes`.

    Example:

    `http://example.com/foo//bar` -> `http://example.com/foo/bar`

- Remove hash fragment. Option `:remove_hash`.

    Example:

    `http://example.com/foo#bar` -> `http://example.com/foo`

- Remove known commonly used tracking query parameters. Option `:remove_tracking`.

    Example:

    `http://example.com/?utm_source=whatever` -> `http://example.com/`

- Sort query string. Option `:sort_query`.

    Example:

    `http://example.com/products/?foo=bar&baz` -> `http://example.com/products?baz&foo=bar`

## Contributing

1. Fork it (https://github.com/rwz/normalize_url/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
