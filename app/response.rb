class Response
  attr_reader :status_code, :body

  def initialize(status_code, body = nil)
    @status_code = status_code
    @headers = {}
    @body = body

    return unless body

    @headers['Content-Type'] = 'text/plain'
    @headers['Content-Length'] = body.bytes.length
  end

  def encode
    return @encode if @encode

    @encode = 'HTTP/1.1 '

    # TODO: Exhaustive list of status codes
    case @status_code
    when 200
      @encode << '200 OK'
    when 404
      @encode << '404 NOT FOUND'
    end

    @encode << "\r\n"

    @encode << @headers.map { |key, value| "#{key}: #{value}\r\n" }.join

    @encode << "\r\n"

    @encode << body if @body

    @encode
  end

  def self.ok
    @ok ||= new(200)
  end

  def self.not_found
    @not_found ||= new(404)
  end
end
