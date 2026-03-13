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
        


        match = @router.match(request)
        if match 
          body = match[:block].call
          message = 200
          content_type = "text/html"
        elsif File.exist?("public#{request.resource}")
          
          message = 200
          case request.resource.split(".")[-1] 
          when "css"
            body = File.read("public#{request.resource}")
            content_type = "text/css"
          when "html"
            body = File.read("public#{request.resource}")
            content_type = "text/html"
          when "png"
            body = File.binread("public#{request.resource}")
            content_type = "image/png"
          when "jpeg"
            body = File.binread("public#{request.resource}")
            content_type = "image/jpeg"
          when "jpg"
            body = File.binread("public#{request.resource}")
            content_type = "image/jpeg"
          when "js"
            body = File.read("public#{request.resource}")
            content_type = "text/javascript"
          when "pdf"
            body = File.binread("public#{request.resource}")
            content_type = "application/pdf"
          else
            body = File.read("public#{request.resource}")
            content_type = "text/plain"
          end
        else
          message = 404
          body = nil
          content_type = nil
        end
        session.print create_response(request.version, message, content_type, body)
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


  def create_response(version, message, content_type = nil, body = nil)
    if message == 404
      return "#{version} #{message}\r\n\r\n"
    end
    return "#{version} #{message}\r\nContent-Type: #{content_type}\r\n\r\n#{body}\r\n\r\n"
  end
end

def slim(path, object = Object.new)
  template = Slim::Template.new(path)
  template.render(object, wat: "woot")
end
