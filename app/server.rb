require_relative 'request'
require_relative 'response'
require 'socket'
require 'optparse'

class Server
  def initialize(opts)
    @file_dir = opts[:file_dir]
  end

  def start
    server = TCPServer.new('localhost', 4221)

    loop do
      client_socket, _client_address = server.accept
      # TODO: limit connections
      Thread.new { start_connection(client_socket) }
    end
  end

  private

  def start_connection(client_socket)
    # TODO: Timeout
    loop do
      request = Request.try_create(client_socket)

      next unless request

      res = process_request(request)
      res.send(client_socket, response_encoding(request))

      break if res.headers['Connection'] == 'close'
    rescue StandardError => e
      puts "Error reading from client socket #{e.message}"
      break
    end

    client_socket.close
  end

  def response_encoding(request)
    request.accept_encodings.include?('gzip') ? :gzip : :identity
  end

  def process_request(req)
    res = if req.method == 'GET'
            process_get_request(req)
          elsif req.method == 'POST'
            process_post_request(req)
          else
            Response.ok
          end

    res.set_header('Connection', 'close') if req.headers['Connection'] == 'close'
    res
  end

  def process_get_request(req)
    if req.path == '/'
      Response.ok
    elsif req.path.start_with?('/echo')
      echo(req)
    elsif req.path.start_with?('/user-agent')
      Response.new(200, req.user_agent)
    elsif req.path.start_with?('/files')
      files(req)
    else
      Response.not_found
    end
  end

  def process_post_request(req)
    if req.path.start_with?('/files')
      write_file(req)
    else
      Response.not_found
    end
  end

  def echo(req)
    _, msg = req.path.split('/').map.drop(1)

    Response.new(200, msg)
  end

  def files(req)
    _, name = req.path.split('/').map.drop(1)

    path = @file_dir && name ? File.join(@file_dir, name) : nil
    return Response.not_found if !path || !File.exist?(path)

    Response.new(200, File.open(path))
  end

  def write_file(req)
    _, name = req.path.split('/').map.drop(1)
    path = File.join(@file_dir, name)
    File.write(path, req.raw_body)
    Response.new(201)
  end
end

print('Logs from your program will appear here!')
options = {}
key, value = ARGV
options[:file_dir] = value if key == '--directory'
Server.new(options).start
