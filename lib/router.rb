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
    route_array = []
    route.each do |part|
      route_array << {name: part, dynamic: (part[0] == ":")}
    end
    @routes << {method: method, route: route_array, block: blk}
  end

  def match(request)
    if request.class == Request
      @routes.each do |route|
        if route[:method] == request.method
          request_resource = request.resource.split("/")
          if route[:route].length == request_resource.length
            is_correct = true
            route[:params] = {}
            (0..(route[:route].length - 1)).each do |i|
              if route[:route][i][:dynamic]
                symbol = route[:route][i][:name].delete(":").to_sym
                route[:params][symbol] = request_resource[i]
              else
                if route[:route][i][:name] != request_resource[i]
                  is_correct = false
                end
              end
            end
            if is_correct
              return route
            end
          end
        end
      end
    elsif request.class == Hash
      @routes.each do |route|
        if route[:method] == request[:method]
          request_resource = request[:resource].split("/")
          if route[:route].length == request_resource.length
            is_correct = true
            route[:params] = {}
            (0..(route[:route].length - 1)).each do |i|
              if route[:route][i][:dynamic]
                symbol = route[:route][i][:name].delete(":").to_sym
                route[:params][symbol] = request_resource[i]
              else
                if route[:route][i][:name] != request_resource[i]
                  is_correct = false
                end
              end
            end
            if is_correct
              return route
            end
          end
        end
      end
    end
    false
  end

  
end