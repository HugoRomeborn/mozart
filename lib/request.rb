

class Request
  attr_reader :method, :resource
  def initialize(request)
    parse(request)
  end
  
  def parse(request)
    content = request.split("/\r?\n/")
    
    @method, @resource, @version = content.shift.split

    if @version != "HTTP/1.1"
      raise "wrong version of HTTP, was #{@version} should be HTTP/1.1"
    end
    
  end
end