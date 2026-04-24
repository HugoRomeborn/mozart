class Response
  attr_reader :message

  @@content_types = {
    plain: "text/plain",
    css: "text/css",
    html: "text/html",
    js: "text/javascript",
    png: "image/png",
    jpeg: "image/jpeg",
    jpg: "image/jpeg",
    pdf: "application/pdf"
  }
  def initialize(match, params, request)
    @request = request
    if match 

      if match[:params] != nil
        params.merge!(match[:params])
      end

      @body = match[:block].call(params)
      if @body.class == Hash
        @message = @body[:message]
        @body = @body[:resource]
      else
        @message = 200
        @content_type = "text/html"
      end

    elsif @request.resource != "/" && File.exist?("public#{@request.resource}")
      @body = File.binread("public#{@request.resource}")
      @message = 200
      if @request.resource.split(".").length == 1
        @content_type =  @@content_types[:plain]
      else
        @content_type =  @@content_types[@request.resource.split(".")[-1].to_sym]
      end

    else
      @message = 404
    end

  end

  def write_message()
    if @message == 404
      return "#{@request.version} #{@message} Not Found\r\n\r\n"
    elsif @message == 303
      return "#{@request.version} #{@message} See Other\r\nLocation: #{@body}\r\n\r\n"
    end
    return "#{@request.version} #{@message} OK\r\nContent-Type: #{@content_type}\r\n\r\n#{@body}\r\n\r\n"
  end
end




def redirect(resource)
  return {resource: resource, message: 303}
end