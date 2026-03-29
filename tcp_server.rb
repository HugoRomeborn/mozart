require 'socket'
require_relative 'lib/request'
require_relative 'lib/router'

class HTTPServer
  attr_reader :router
  def initialize(port, router)
    @port = port

    @router = router
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
        params = {}
        params.merge!(request.params)
        
        if match 

          if match[:params] != nil
            params.merge!(match[:params])
          end
          
          p params
          body = match[:block].call(params)
          if body.class == Hash
            message = body[:message]
            body = body[:resource]

          else
            message = 200
          end
          content_type = "text/html"

        elsif request.resource != "/" && File.exist?("public#{request.resource}")
          body = File.binread("public#{request.resource}")
          message = 200
          case request.resource.split(".")[-1] 
          when "css"
            content_type = "text/css"
          when "html"
            content_type = "text/html"
          when "png"
            content_type = "image/png"
          when "jpeg"
            content_type = "image/jpeg"
          when "jpg"
            content_type = "image/jpeg"
          when "js"
            content_type = "text/javascript"
          when "pdf"
            content_type = "application/pdf"
          else
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
    elsif message == 303
      return "#{version} #{message} See Other\r\nLocation: #{body}\r\nContent-Type: #{content_type}\r\n\r\n"
    end
    return "#{version} #{message}\r\nContent-Type: #{content_type}\r\n\r\n#{body}\r\n\r\n"
  end

  def redirect(resource)
    return {resource: resource, message: 303}
  end
  
end

def slim(path, object = Object.new)
  template = Slim::Template.new("views/#{path}.slim")
  doc = template.render(object, wat: "woot")
  if File.exist?("views/layout.slim")
    template = Slim::Template.new("views/layout.slim")
    layout = template.render(object, wat: "woot")
    doc =layout.gsub("==yield", doc)
  end
  doc
end

