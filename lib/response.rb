
class Response

  def initialize(routes)
    @routes = routes

  end

  def respond(request)
    route = resource_exists?(request)

    case route
    when false
      message = 404
      html = "<h1>ERROR 404 - page not found</h1>"
    else
      message = 200
      html = route[:block].call
    end

    return "#{request.version} #{message}\r\nContent-Type: text/html\r\n\r\n#{html}"
  end

  def resource_exists?(request)
    @routes.each do |route|
      if route[:method] == request.method
        if route[:route] == request.resource
          return route
        end
      end
    end
    false
  end

end