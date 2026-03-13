require 'slim'

require_relative 'tcp_server'

r = Router.new


r.get('/hello') do
  @senap = "sdsfdfsdf"
  slim('views/index.slim', self)
end

r.get('/world') do
  
end


server = HTTPServer.new(4567, r)
server.start
