class Request
  HTTP_METHOD_REGEX = /^(GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD|TRACE|CONNECT)/.freeze

  attr_reader :method, :path, :headers, :raw_body

  def initialize(method, path, headers, raw_body)
    @method = method
    @path = path
    @headers = headers
    @raw_body = raw_body
  end

  def user_agent
    @headers['User-Agent']
  end

  def accept_encodings
    @accept_encodings ||= @headers['Accept-Encoding']&.split(',')&.map(&:strip) || []
  end

  def self.try_create(socket)
    request_line = socket.gets
    return nil unless HTTP_METHOD_REGEX.match(request_line)

    method, path = request_line.split("\s").map(&:chomp)

    headers = {}
    body = nil

    loop do
      line = socket.gets&.chomp
      break if line.nil? || line == ''

      key, value = line.split(':', 2).map(&:strip)
      headers[key] = value.strip
    end

    if headers['Content-Length']
      body_length = headers['Content-Length'].to_i
      body = socket.gets(body_length)
    end

    Request.new(method, path, headers, body)
  end
end
