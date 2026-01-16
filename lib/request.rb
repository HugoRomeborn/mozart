require 'debug'

class Request
  attr_reader :header, :content, :method, :resource, :version
  def initialize(request)
    parse(request)
  end
  
  def parse(request)
    @content = {}
    @header = {}
    head, body = request.split(/\r?\n\r?\n/)
    binding.break
    p head; p body
    head = head.split(/\r?\n/)
    if body then body = body.split(/\r?\n/) end

    @method, @resource, @version = head.shift.split


    if @version != "HTTP/1.1"
      raise "wrong version of HTTP, was #{@version} should be HTTP/1.1"
    end
    head.each do |line|
      line.strip
      line = line.split(":")
      key = line.shift.strip
      line = line[0]
      line.split(",")
      @header[line[0].strip] = ( line.length == 1 ? line[0] : line )

      # if line[0] == "Host:"
      #   @header[:host] = line[1]
      # end

      # if line[0] == "Accept-Language:" 
      #   @header[:languages] = line
      #   @header[:languages].shift
      # end

      # if line[0] == "Content-Type:"
      #   @header[:content_type] = line
      #   @header[:content_type].shift
      # end

      # if line[0] == "Content-Length:"
      #   @header[:content_length] = line
      #   @header[:content_length].shift
      # end
    
        
      
      
    end
  end
end