# Builds an HTTP/1.1 response from a matched route, a static file, or a 404.
#
# Resolution order:
# 1. If a router match is provided, the route's block is called and its return
#    value becomes the body (or a redirect instruction).
# 2. If the requested resource exists under `public/`, it is served as a static file.
# 3. Otherwise a 404 Not Found response is produced.
class Response
  # @return [Integer] the HTTP status code (200, 303, or 404)
  attr_reader :message
 
  # Maps file-extension symbols to their MIME type strings.
  #
  # @return [Hash{Symbol => String}]
  @@content_types = {
    plain: "text/plain",
    css:   "text/css",
    html:  "text/html",
    js:    "text/javascript",
    png:   "image/png",
    jpeg:  "image/jpeg",
    jpg:   "image/jpeg",
    pdf:   "application/pdf"
  }
 
  # Creates a new Response.
  #
  # @param match  [Hash, false] the route match returned by {Router#match},
  #   or +false+ if no route matched
  # @param params [Hash{String, Symbol => String}] merged request parameters
  # @param request [Request] the originating HTTP request
  def initialize(match, params, request)
    @request = request
 
    if match
      params.merge!(match[:params]) if match[:params]
 
      @body = match[:block].call(params)
 
      if @body.class == Hash
        # Block returned a redirect instruction produced by {#redirect}
        @message = @body[:message]
        @body    = @body[:resource]
      else
        @message      = 200
        @content_type = "text/html"
      end
 
    elsif @request.resource != "/" && File.exist?("public#{@request.resource}")
      @body    = File.binread("public#{@request.resource}")
      @message = 200
      if @request.resource.split(".").length == 1
        @content_type = @@content_types[:plain]
      else
        @content_type = @@content_types[@request.resource.split(".")[-1].to_sym]
      end
 
    else
      @message = 404
    end
  end
 
  # Serialises the response into a raw HTTP/1.1 message string.
  #
  # @return [String] the full HTTP response string ready to be written to the socket
  def write_message
    case @message
    when 404
      "#{@request.version} #{@message} Not Found\r\n\r\n"
    when 303
      "#{@request.version} #{@message} See Other\r\nLocation: #{@body}\r\n\r\n"
    else
      "#{@request.version} #{@message} OK\r\nContent-Type: #{@content_type}\r\n\r\n#{@body}\r\n\r\n"
    end
  end
end
 
# Returns a redirect instruction hash that {Response} recognises as a 303 See Other.
#
# @param resource [String] the path the client should be redirected to
# @return [Hash{Symbol => String, Integer}] a hash with `:resource` and `:message` (303)
def redirect(resource)
  { resource: resource, message: 303 }
end
 
# Renders a Slim template, optionally wrapped in `views/layout.slim`.
#
# The rendered partial is injected into the layout wherever the literal
# string `"==yield"` appears.
#
# @param path   [String] the template name (without extension) relative to `views/`
# @param object [Object] the binding object whose instance variables are
#   available inside the template (default: a plain +Object+)
# @return [String] the fully rendered HTML string
def slim(path, object = Object.new)
  template = Slim::Template.new("views/#{path}.slim")
  doc      = template.render(object, wat: "woot")
 
  if File.exist?("views/layout.slim")
    template = Slim::Template.new("views/layout.slim")
    layout   = template.render(object, wat: "woot")
    doc      = layout.gsub("==yield", doc)
  end 
  doc
end