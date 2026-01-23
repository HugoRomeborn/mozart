require_relative 'spec_helper'

class RequestTest < Minitest::Test

  def test_parses_http_method_from_simple_get
    request_string = File.read('./get-index.request.txt')
    request = Request.new(request_string)

    assert_equal 'GET', request.method
  end

  def test_parses_resource_from_simple_get
    request_string = File.read('./get-index.request.txt')
    request = Request.new(request_string)

    assert_equal '/', request.resource
  end

  def test_parses_host_from_simple_get
    request_string = File.read('./get-index.request.txt')
    request = Request.new(request_string)

    assert_equal 'developer.mozilla.org', request.header["Host"]
  end

  def test_parses_language_from_simple_get
    request_string = File.read('./get-index.request.txt')
    request = Request.new(request_string)

    assert_equal 'fr', request.header["Accept-Language"]
  end

  def test_parses_User_Agent_from_simple_get
    request_string = File.read('./get-fruits-with-filter.request.txt')
    request = Request.new(request_string)

    assert_equal 'ExampleBrowser/1.0', request.header["User-Agent"]
  end

  def test_parses_accept_encoding_from_simple_get
    request_string = File.read('./get-fruits-with-filter.request.txt')
    request = Request.new(request_string)

    assert_equal ["gzip", "deflate"], request.header["Accept-Encoding"]
  end

  def test_parses_username_from_simple_login_post
    request_string = File.read('./post-login.request.txt')
    request = Request.new(request_string)

    assert_equal 'grillkorv', request.params["username"]
  end

  def test_parses_password_from_simple_login_post
    request_string = File.read('./post-login.request.txt')
    request = Request.new(request_string)

    assert_equal 'verys3cret!', request.params["password"]
  end

  def test_parses_filter_from_simple_get
    request_string = File.read('./get-fruits-with-filter.request.txt')
    request = Request.new(request_string)

    assert_equal 'bananas', request.params["type"]
    assert_equal '4', request.params["minrating"]
  end
end

