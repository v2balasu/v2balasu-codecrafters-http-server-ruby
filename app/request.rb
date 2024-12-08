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

  def self.try_create(socket)
    request_line = socket.gets
    return nil unless HTTP_METHOD_REGEX.match(request_line)

    method, path = request_line.split("\s").map(&:chomp)

    headers = {}

    loop do
      line = socket.gets&.chomp
      break if line.nil? || line == ''

      key, value = line.split(':', 2).map(&:strip)
      headers[key] = value
    end

    Request.new(method, path, headers, nil)
  end
end
