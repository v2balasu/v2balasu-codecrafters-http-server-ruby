require 'socket'

# You can use print statements as follows for debugging, they'll be visible when running tests.
print('Logs from your program will appear here!')

server = TCPServer.new('localhost', 4221)

HTTP_METHOD_REGEX = /^(GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD|TRACE|CONNECT)/.freeze
HTTP_RESPONSE_OK = "HTTP/1.1 200 OK\r\n\r\n".freeze
HTTP_RESPONSE_NOT_FOUND = "HTTP/1.1 404 Not Found\r\n\r\n".freeze

def start_connection(client_socket)
  # TODO: Timeout
  loop do
    req = client_socket.gets

    if req&.match(HTTP_METHOD_REGEX)
      res = process_request(req)
      client_socket.puts(res)
    end
  rescue StandardError => e
    puts "Error reading from client socket #{e.message}"
    break
  end

  client_socket.close
end

def process_request(req)
  req_method, path = req.split("\s")
  return HTTP_RESPONSE_OK unless req_method == 'GET'

  path == '/' ? HTTP_RESPONSE_OK : HTTP_RESPONSE_NOT_FOUND
end

loop do
  client_socket, _client_address = server.accept
  # TODO: limit connections
  Thread.new { start_connection(client_socket) }
end
