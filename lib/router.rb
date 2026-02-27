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
    @routes << {method: method, route: route, block: blk}
  end
end

