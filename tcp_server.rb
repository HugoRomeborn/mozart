require 'socket'
require_relative 'lib/request'
require_relative 'lib/router'
require_relative 'lib/response'

class HTTPServer

  def initialize(port, router)
    @port = port

    @router = router
    @responder = Responder.new()
  end

  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"

    while session = server.accept
      data = receive_request(session)
      case data
      when nil
      else
        request = Request.new(data)
        


        match = router.match(request)

        if match 
          html = match[block].call
        elsif file_exists?()
          
        else
          404!
          response  = @responder.respond(request)
        end
        session.print response
      end
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

def file_exists?(resource)
  Dir.chdir("public")
  content
end