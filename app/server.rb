require 'socket'

# You can use print statements as follows for debugging, they'll be visible when running tests.
print('Logs from your program will appear here!')

server = TCPServer.new('localhost', 4221)

HTTP_METHOD_REGEX = /^(GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD|TRACE|CONNECT)/.freeze

def start_connection(client_socket)
  # TODO: Timeout
  loop do
    req = client_socket.gets
    client_socket.puts("HTTP/1.1 200 OK\r\n\r\n") if req&.match(HTTP_METHOD_REGEX)
  rescue StandardError => e
    puts "Error reading from client socket #{e.message}"
    break
  end

  client_socket.close
end

loop do
  client_socket, _client_address = server.accept
  # TODO: limit connections
  Thread.new { start_connection(client_socket) }
end
