class Router 
  attr_reader :routes
  def initialize
    @routes = []
  end

  def get(route, &blk)

    add_route("GET", route, blk)
  end

  def post(route, &blk)
    add_route("POST", route, blk)
  end

  def add_route(method, route, blk)
    route = route.split("/")   
    @routes << {method: method, route: route, block: blk}
  end

  def match(request)
    @routes.each do |route|
      p route[:method]
      p request.method
      if route[:method] == request.method
        p route[:route]
        p request.resource.split("/")
        if route[:route][1] == request.resource.split("/")[1]
          p "steg 1"
          if request.resource.split("/").length == route[:route].length
            p "steg 2"
            route[:params] = {}
            if request.resource.split("/").length > 2 && route[:route].length > 2 && route[:route].join.include?(":")
              p "här är params i url"
              route[:params][route[:route][2]] = request.resource.split("/")[2]
            end
            p route
            return route
          end
        end
      end
    end
    false
  end
end