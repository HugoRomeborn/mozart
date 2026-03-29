require 'slim'

require_relative 'tcp_server'

r = Router.new


r.get('/:test/hello') do |params|
  @senap = params[:test]
  slim('index', self)
end

r.get('/ghj') do |params|
  slim('hello', self)

end

r.post('/hek') do |params|
  p params
  redirect("/ghj")
end


$server = HTTPServer.new(4567, r)
$server.start
