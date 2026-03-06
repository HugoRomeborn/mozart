
class Responder

  def initialize()
  end

  def respond(request)
    route = @router.resource_exists?(request)

    case route
    when false
      message = 404
      html = "<h1>ERROR 404 - page not found</h1>"
      content_type = text/html
    else
      message = 200
      html = route[:block].call
      content_type = text/html 
    end

    return "#{request.version} #{message}\r\nContent-Type: #{content_type}\r\n\r\n#{html}\r\n\r\n"
  end

  

end