require 'socket'
require_relative 'lib/request'
require_relative 'lib/router'
require_relative 'lib/response'
require 'debug'

include Response
include Router
include Request
 
# A minimal HTTP/1.1 server built on top of Ruby's +TCPServer+.
#
# Accepts incoming TCP connections in a blocking loop, reads the full HTTP
# request (including body when a +Content-Length+ header is present), dispatches
# it through the provided {Router}, and writes the {Response} back to the client.
#
# @example
#   router = Router.new
#   router.get('/') { |_params| '<h1>Hello</h1>' }
#
#   server = HTTPServer.new(4567, router)
#   server.start
class HTTPServer
  # @return [Router] the router used to match incoming requests to handler blocks
  attr_reader :router
 
  # Creates a new HTTPServer.
  #
  # @param port   [Integer] the TCP port to listen on
  # @param router [Router]  the router that maps requests to handler blocks
  def initialize(port, router)
    @port   = port
    @router = router
  end
 
  # Starts the server and enters the accept loop.
  #
  # Blocks indefinitely, handling one request per connection.  For each
  # accepted connection the method:
  # 1. Reads the raw HTTP data via {#receive_request}
  # 2. Parses it into a {Request}
  # 3. Finds a matching route via {Router#match}
  # 4. Builds a {Response} and writes it back to the socket
  #
  # @return [void]
  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"
 
    while session = server.accept
      data = receive_request(session)
      case data
      when nil
        # nothing to do – empty request
      else
        request = Request.new(data)
 
        match  = @router.match(request)
        params = {}
        params.merge!(request.params)
 
        response = Response.new(match, params, request)
        session.print response.write_message
      end
      session.close
    end
  end
 
  private
 
  # Reads a complete HTTP request from the given socket session.
  #
  # Reads header lines until a blank line is encountered, then reads
  # +Content-Length+ bytes of body if the header is present.
  #
  # @param session [TCPSocket] the accepted client socket
  # @return [String] the raw HTTP request string (headers + optional body)
  def receive_request(session)
    data = ''
 
    while line = session.gets and line !~ /^\s*$/
      data += line
    end
    request = Request.new(data)
 
    if request.header["Content-Length"]
      length = request.header["Content-Length"].to_i
      body   = session.read(length)
      data  += "\r\n" + body
    end
 
    puts "RECIEVED REQUEST"
    puts '-' * 40
    puts data
    puts '-' * 40
 
    data
  end
end