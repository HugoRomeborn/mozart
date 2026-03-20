require 'slim'

require_relative 'tcp_server'

r = Router.new


r.get('/hello/:test') do |params|
  @senap = params[":test"]
  slim('index', self)
end

r.get('/ghj') do
  
end


server = HTTPServer.new(4567, r)
server.start
