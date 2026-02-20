require 'socket'
require_relative 'lib/request'
require_relative 'app'
require_relative 'get'

class HTTPServer

  def initialize(port, router)
    @port = port

    @routes = router.routes
  end

  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"
    Dir.chdir("views")

    while session = server.accept
      data = receive_request(session)

      request = Request.new(data)
      if resource_exists?(request) != false
        

      html = error_handler(route)

      respond(session, html, request)
      session.close
    end
  end
  
  def parse_document(document)
  end

  def respond(session, html, request)
      session.print "#{request.version} #{@message}\r\n"
      session.print "Content-Type: text/html\r\n"
      session.print "\r\n"
      session.print html
  end
  
  def error_handler(route)
    if route ==  nil || !File.exist?(route)
      html = "<h1>ERROR 404 - page not found</h1>"
      @message = 404
    else
      html = File.read(route)
      @message = 200
    end
    return html
  end

  def receive_request(session)
      data = ''
      while line = session.gets and line !~ /^\s*$/
        data += line
      end

      puts "RECEIVED REQUEST"
      puts '-' * 40
      puts data
      puts '-' * 40
      return data
  end

  def resource_exists?(request)
    @routes.each do |route|
      if route[:method] == request.method
        if route[route] == request.resource
          return route
        end
      end
    end
    false
  end
end

