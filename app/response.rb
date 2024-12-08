require 'stringio'
require 'zlib'

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

  def send(socket, encoding)
    return send_gzip(socket) if encoding == :gzip

    send_identity(socket)
  end

  def self.ok
    @ok ||= new(200)
  end

  def self.not_found
    @not_found ||= new(404)
  end

  private

  def response_content_meta
    metadata = 'HTTP/1.1 '

    # TODO: Exhaustive list of status codes
    case @status_code
    when 200
      metadata << '200 OK'
    when 201
      metadata << '201 Created'
    when 404
      metadata << '404 Not Found'
    end

    metadata << "\r\n"

    metadata << @headers.map { |key, value| "#{key}: #{value}\r\n" }.join

    metadata << "\r\n"

    metadata
  end

  def send_gzip(socket)
    gzip_stream = Zlib::GzipWriter.new(StringIO.new)
    if body.is_a?(File)
      IO.copy_stream(body, gzip_stream)
      body.cose
    elsif body
      gzip_stream.write(body)
    end

    mem_stream = gzip_stream.finish
    @headers['Content-Encoding'] = 'gzip'
    @headers['Content-Length'] = mem_stream.size

    res_content = response_content_meta
    socket.puts(res_content)

    mem_stream.rewind
    IO.copy_stream(mem_stream, socket)
    mem_stream.close
  end

  def send_identity(socket)
    res_content = response_content_meta

    if body.is_a?(File)
      socket.puts(res_content)
      IO.copy_stream(body, socket)
      body.close
      return
    end

    res_content << body if body
    socket.puts(res_content)
  end
end
