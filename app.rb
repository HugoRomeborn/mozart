require 'slim'

require_relative 'tcp_server'

r = Router.new


r.get('/hello') do
  @senap = "sdsfdfsdf"
  Slim::Template.new('views/index.slim').render({wat: "woot"})
  #File.read("./index.html")
end


server = HTTPServer.new(4567, r)
server.start
