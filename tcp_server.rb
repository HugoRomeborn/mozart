require 'socket'
require_relative 'lib/request'

class HTTPServer

  def initialize(port)
    @port = port

    @routes = {
      "/" => "index.html",
      "/what" => "",
      "/about" => "<h1>How do I do this?</h1>\n<h2>Welcome to my life</h2>"
    }
  end

  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"
    Dir.chdir("views")

    while session = server.accept
      data = ''
      while line = session.gets and line !~ /^\s*$/
        data += line
      end

      puts "RECEIVED REQUEST"
      puts '-' * 40
      puts data
      puts '-' * 40

      request = Request.new(data)

      route = @routes[request.resource]


      if route ==  nil
        html = "<h1>ERROR 404 - page not found</h1>"
        message = 404
      elsif !File.exist?(route)
        html = "<h1>ERROR 502 - Bad gateway"
        message = 502
      else
        html = File.read(route)
        message = 200
      end
      session.print "HTTP/1.1 #{message}\r\n"
      session.print "Content-Type: text/html\r\n"
      session.print "\r\n"
      session.print html
      session.close
    end
  end
  
  def parse_document(document)
    
  
end

server = HTTPServer.new(4567)
server.start
