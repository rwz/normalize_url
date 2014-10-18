require "spec_helper"

describe NormalizeUrl do
  def n(*args)
    described_class.process(*args)
  end

  it "raises ArgumentError when input is not an URL" do
    action = ->{ n("http://") }
    message = %{"http://" is not a URL}
    expect(&action).to raise_error(ArgumentError, message)
  end

  it "raises ArgumentError when input is not an abolute URL" do
    action = ->{ n("not@url") }
    message = "only absolute URLs can be normalized"
    expect(&action).to raise_error(ArgumentError, message)
  end

  it "raises ArgumentError when input is not an HTTP(S) URL" do
    action = ->{ n("ftp://example.com") }
    message = "only HTTP/HTTPS URLs can be normalized"
    expect(&action).to raise_error(ArgumentError, message)
  end

  it "normalizes punycode" do
    expect(n("http://www.詹姆斯.com/")).to eq("http://www.xn--8ws00zhy3a.com/")
  end

  it "downcases host and scheme" do
    expect(n("HTTP://EXAMPLE.COM/FOO")).to eq("http://example.com/FOO")
  end

  it "normalizes dot-segments" do
    expect(n("http://example.com/foo/bar/../../")).to eq("http://example.com/")
  end

  it "strips trailing slash" do
    expect(n("http://example.com/products/")).to eq("http://example.com/products")
  end

  it "skips trailing slash when required" do
    expect(n("http://example.com/products/", remove_trailing_slash: false)).to eq("http://example.com/products/")
  end

  it "removes empty query" do
    expect(n("http://example.com/?")).to eq("http://example.com/")
  end

  it "sorts query params" do
    expect(n("http://example.com/?b=bar&a=foo")).to eq("http://example.com/?a=foo&b=bar")
  end

  it "doesn't modify query params" do
    expect(n("http://example.com/?foo=BAR%26BAZZ")).to eq("http://example.com/?foo=BAR%26BAZZ")
  end

  it "skips sorting query when required" do
    expect(n("http://example.com/?b=bar&a=foo", sort_query: false)).to eq("http://example.com/?b=bar&a=foo")
  end

  it "removes tracking query params" do
    expect(n("http://example.com/?utm_source=foo")).to eq("http://example.com/")
    expect(n("http://example.com/?utm_medium=foo")).to eq("http://example.com/")
    expect(n("http://example.com/?utm_term=foo")).to eq("http://example.com/")
    expect(n("http://example.com/?utm_content=foo")).to eq("http://example.com/")
    expect(n("http://example.com/?utm_campaign=foo")).to eq("http://example.com/")
    expect(n("http://example.com/?sms_ss=foo")).to eq("http://example.com/")
    expect(n("http://example.com/?awesm=foo")).to eq("http://example.com/")
    expect(n("http://example.com/?xtor=foo")).to eq("http://example.com/")
    expect(n("http://example.com/?PHPSESSID=foo")).to eq("http://example.com/")
    expect(n("http://example.com/?a=a&xtor=foo&b=b")).to eq("http://example.com/?a=a&b=b")
  end

  it "removes query params provided in options" do
    expect(n("http://example.com/?a=a&xtor=foo&b=b&c=c", remove_params: :b)).to eq("http://example.com/?a=a&c=c")
    expect(n("http://example.com/?a=a&xtor=foo&b=b&c=c", remove_params: ["b", :c])).to eq("http://example.com/?a=a")
  end

  it "skips removing tracking params if required" do
    expect(n("http://example.com/?xtor=foo", remove_tracking: false)).to eq("http://example.com/?xtor=foo")
  end

  it "removes repeating slashes in path" do
    expect(n("http://example.com/foo///products")).to eq("http://example.com/foo/products")
  end

  it "skips removing repeating slashes when required" do
    expect(n("http://example.com/f///p", remove_repeating_slashes: false)).to eq("http://example.com/f///p")
  end

  it "removes hash fragment" do
    expect(n("http://example.com/foo#bar")).to eq("http://example.com/foo")
  end

  it "skips removing hash fragment when required" do
    expect(n("http://example.com/foo#bar", remove_hash: false)).to eq("http://example.com/foo#bar")
  end
end
