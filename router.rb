class Router 

  def initialize
    @routes = []
  end

  def get(route, &blk)
    add_route(:get, route, blk)
  end

  def post(route, &blk)
    add_route(:post, route, blk)
  end

  def add_route(method, route, blk)
    routes << {method: method, route: route, block: blk}
  end
end

