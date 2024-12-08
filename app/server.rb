require_relative 'request'
require_relative 'response'
require 'socket'

# You can use print statements as follows for debugging, they'll be visible when running tests.
print('Logs from your program will appear here!')

server = TCPServer.new('localhost', 4221)

def start_connection(client_socket)
  # TODO: Timeout
  loop do
    message = client_socket.gets&.chomp
    request = Request.try_create(message)

    next unless request

    res = process_request(request)
    client_socket.puts(res.encode)
  rescue StandardError => e
    puts "Error reading from client socket #{e.message}"
    break
  end

  client_socket.close
end

def process_request(req)
  return Response.ok unless req.method == 'GET'

  if req.path == '/'
    Response.ok
  elsif req.path.start_with?('/echo')
    echo(req)
  else
    Response.not_found
  end
end

def echo(req)
  _, msg = req.path.split('/').map(&:chomp).drop(1)

  Response.new(200, msg)
end

loop do
  client_socket, _client_address = server.accept
  # TODO: limit connections
  Thread.new { start_connection(client_socket) }
end
