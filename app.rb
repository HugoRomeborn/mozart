require_relative 'tcp_server'

r = Router.new


r.get('/hello') do
  return 1 + 2
end


server = HTTPServer.new(4567, r)
server.start
