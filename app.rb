require 'slim'

require_relative 'tcp_server'

r = Router.new


r.get('/hello') do
  @senap = "sdsfdfsdf"
  template = Slim::Template.new('views/index.slim')
  template.render(self, wat: "woot")
  #File.read("./index.html")
end

r.get('/world') do
  
end


server = HTTPServer.new(4567, r)
server.start
