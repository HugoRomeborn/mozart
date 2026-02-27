require 'socket'
require_relative 'lib/request'
require_relative 'lib/router'
require_relative 'lib/response'

class HTTPServer

  def initialize(port, router)
    @port = port

    @routes = router.routes
    @responder = Response.new(router.routes)
  end

  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"

    while session = server.accept
      data = receive_request(session)

      request = Request.new(data)
      

        

      response  = @responder.respond(request)

      session.print response
      session.close
    end
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

end

