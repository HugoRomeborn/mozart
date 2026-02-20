require 'debug'


class Request
  attr_reader :header, :params, :method, :resource, :version
  def initialize(request)
    parse(request)
  end
  
  def parse(request)
    @header = {}
    @params = {}

    head, body = request.split(/\r?\n\r?\n/)
    head = head.split(/\r?\n/)
    

    @method, @resource, @version = head.shift.split

    if @version != "HTTP/1.1"
      raise "wrong version of HTTP, was #{@version} should be HTTP/1.1"
    end
    if @resource.include?("?")
      string = @resource.split("?")
      content = string[1]
      
      param = {}
      content = content.split("&")
      content.each do |x| 
        x = x.split("=")
        param[x[0]] = x[1]
      end
      param.to_h
      @params.merge!(param)
    end

    head.each do |line|
      line.strip
      line = line.split(":")
      key = line.shift.strip
      line = line[0]
      line = line.split(",")
      @header[key.strip] = ( line.length == 1 ? line[0].strip : line.each{|x| x.strip!})
    end

    if body != nil
      param = {}
      body.strip!
      content = body.split("&")
      content.each do |x| 
        x = x.split("=")
        param[x[0]] = x[1]
      end
      param.to_h
      @params.merge!(param)
    end
  end
end