require 'socket'
require_relative 'lib/request'
require_relative 'lib/router'
require_relative 'lib/response'
require 'debug'


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
        
        response = Response.new(match, params, request)
        puts response.write_message
        session.print response.write_message
      end
      session.close
    end
  end
  

  def receive_request(session)
    data = ''

    while line = session.gets and line !~ /^\s*$/
      data += line
    end
    request = Request.new(data)

    if request.header["Content-Length"]
      length = request.header["Content-Length"].to_i
      body = session.read(length)   
      data += "\r\n" + body         
    end
    
    puts "RECIEVED REQUEST"
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

  
  
end

def redirect(resource)
  return {resource: resource, message: 303}
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
