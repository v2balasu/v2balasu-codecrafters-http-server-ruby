class Response
  attr_reader :status_code, :body

  def initialize(status_code, body = nil)
    @status_code = status_code
    @headers = {}
    @body = body

    return unless body

    if body.is_a?(String)
      @headers['Content-Type'] = 'text/plain'
      @headers['Content-Length'] = body.bytes.length
    elsif body.is_a?(File)
      @headers['Content-Type'] = 'application/octet-stream'
      @headers['Content-Length'] = body.size
    end
  end

  def send(socket)
    res_content = 'HTTP/1.1 '

    # TODO: Exhaustive list of status codes
    case @status_code
    when 200
      res_content << '200 OK'
    when 201
      res_content << '201 Created'
    when 404
      res_content << '404 Not Found'
    end

    res_content << "\r\n"

    res_content << @headers.map { |key, value| "#{key}: #{value}\r\n" }.join

    res_content << "\r\n"

    if body.is_a?(File)
      socket.puts(res_content)
      IO.copy_stream(body, socket)
      return
    end

    res_content << body if body
    socket.puts(res_content)
  end

  def self.ok
    @ok ||= new(200)
  end

  def self.not_found
    @not_found ||= new(404)
  end
end
