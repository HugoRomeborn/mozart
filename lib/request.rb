# Parses a raw HTTP/1.1 request string into its constituent parts:
# request line, headers, query parameters, and body parameters.
class Request
  # @return [Hash{String => String, Array<String>}] the parsed HTTP headers
  attr_reader :header
 
  # @return [Hash{String => String}] merged query-string and body parameters
  attr_reader :params
 
  # @return [String] the HTTP method (e.g. "GET", "POST")
  attr_reader :method
 
  # @return [String] the request resource path, possibly including a query string
  attr_reader :resource
 
  # @return [String] the HTTP version string (must be "HTTP/1.1")
  attr_reader :version
 
  # Creates a new Request by parsing the given raw HTTP request string.
  #
  # @param request [String] the raw HTTP request including request line,
  #   headers, and optional body
  # @raise [RuntimeError] if the HTTP version is not "HTTP/1.1"
  def initialize(request)
    parse(request)
  end
 
  private
 
  # Parses the raw HTTP request string and populates {#method}, {#resource},
  # {#version}, {#header}, and {#params}.
  #
  # Handles:
  # - Request line (method, resource, version)
  # - Header fields (stored as arrays)
  # - URL-encoded body parameters (from HTML forms)
  #
  # @param request [String] the raw HTTP request string
  # @return [void]
  # @raise [RuntimeError] if the HTTP version is not "HTTP/1.1"
  def parse(request)
    @header = {}
    @params = {}
 
    head, body = request.split(/\r?\n\r?\n/)
    head = head.split(/\r?\n/)
 
    @method, @resource, @version = head.shift.split
 
    if @version != "HTTP/1.1"
      raise "wrong version of HTTP, was #{@version} should be HTTP/1.1"
    end
 
    if @resource.include?("?")
      string = @resource.split("?")
      content = string[1]
 
      param = {}
      content = content.split("&")
      content.each do |x|
        x = x.split("=")
        param[x[0]] = x[1]
      end
      param.to_h
      @params.merge!(param)
    end
 
    head.each do |line|
      line.strip
      line = line.split(":")
      key = line.shift.strip
      line = line[0]
      line = line.split(",")
      @header[key.strip] = (line.length == 1 ? line[0].strip : line.each { |x| x.strip! })
    end
 
    if body != nil
      param = {}
      body.strip!
      content = body.split("&")
      content.each do |x|
        x = x.split("=")
        param[x[0]] = x[1]
      end
      param.to_h
      @params.merge!(param)
      p @params
    end
  end
end
