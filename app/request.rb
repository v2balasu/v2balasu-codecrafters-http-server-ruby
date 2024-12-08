class Request
  HTTP_METHOD_REGEX = /^(GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD|TRACE|CONNECT)/.freeze

  attr_reader :method, :path, :headers, :raw_body

  def initialize(method, path, headers, raw_body)
    @method = method
    @path = path
    @headers = headers
    @raw_body = raw_body
  end

  def self.try_create(request_raw)
    return nil unless HTTP_METHOD_REGEX.match(request_raw)

    method, path = request_raw.split("\s")

    Request.new(method, path, [], request_raw)
  end
end
