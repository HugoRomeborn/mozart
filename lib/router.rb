# Stores and matches HTTP routes against incoming {Request} objects.
#
# Routes may contain dynamic segments prefixed with `:` (e.g. `/:id/show`),
# which are extracted into a params hash when a match is found.
#
# @example
#   router = Router.new
#   router.get('/users/:id') { |params| "User #{params[:id]}" }
#   router.match(request) # => { method: "GET", route: [...], block: ..., params: { id: "42" } }
class Router
  # @return [Array<Hash>] the list of registered routes
  attr_reader :routes
 
  # Creates a new Router with an empty route list.
  def initialize
    @routes = []
  end
 
  # Registers a GET route.
  #
  # @param route [String] the route pattern (e.g. `"/users/:id"`)
  # @yieldparam params [Hash{Symbol => String}] dynamic and query-string parameters
  # @yieldreturn [String, Hash] the response body, or a redirect hash
  # @return [void]
  def get(route, &blk)
    add_route("GET", route, blk)
  end
 
  # Registers a POST route.
  #
  # @param route [String] the route pattern (e.g. `"/users"`)
  # @yieldparam params [Hash{Symbol => String}] dynamic and body parameters
  # @yieldreturn [String, Hash] the response body, or a redirect hash
  # @return [void]
  def post(route, &blk)
    add_route("POST", route, blk)
  end
 
  # Finds the first registered route that matches the given request.
  #
  # @param request [Request] the incoming HTTP request
  # @return [Hash, false] the matching route hash (including extracted `:params`),
  #   or +false+ if no route matches
  def match(request)
    @routes.each do |route|
      route = correct_route(route, request)
      if route
        return route
      end
    end
    false
  end
 
  private
 
  # Adds a route to the route list, splitting the path into static and dynamic segments.
  #
  # @param method [String] the HTTP method ("GET" or "POST")
  # @param route [String] the route pattern string
  # @param blk [Proc] the handler block
  # @return [void]
  def add_route(method, route, blk)
    route = route.split("/")
    route_array = []
    route.each do |part|
      route_array << { name: part, dynamic: (part[0] == ":") }
    end
    @routes << { method: method, route: route_array, block: blk }
  end
 
  # Tests whether a single stored route matches the given request, and if so,
  # extracts dynamic segment values into the route's `:params` hash.
  #
  # @param route [Hash] a route entry from {#routes}
  # @param request [Request] the incoming HTTP request
  # @return [Hash, nil] the route hash with `:params` populated if it matches,
  #   or +nil+ if it does not
  def correct_route(route, request)
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
    false
  end
end