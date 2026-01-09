

class Request
  attr_reader :method, :resource, :domain :languages
  def initialize(request)
    parse(request)
  end
  
  def parse(request)
    content = request.split("/\r?\n/")
    
    @method, @resource, @version = content.shift.split

    if @version != "HTTP/1.1"
      raise "wrong version of HTTP, was #{@version} should be HTTP/1.1"
    end
    while content.length > 0
      line = content.shift.split

      if line[0] = "Host:"
        @domain = line[2]
      end

      if line[0] = "Accept-Language:"
        @languages = line.split[","]
        @languages.shift
      end
    end
  end
end