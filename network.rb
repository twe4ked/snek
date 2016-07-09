require 'socket'
require 'yaml'

class Network
  def open_socket
    @socket = UDPSocket.new
    @socket.bind '0.0.0.0', 47357
    @socket.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true
    @socket.setsockopt Socket::SOL_SOCKET, Socket::SO_BROADCAST, true
  rescue Errno::EADDRINUSE
    $stderr.puts "Game is already running."
    exit 1
  end

  def receive_updates(&block)
    loop do
      begin
        data, addr = @socket.recvfrom_nonblock 8192
        data = YAML.load(data)
        block.call(data)
      rescue Psych::SyntaxError
      end
    end
  rescue Errno::EAGAIN
  end

  def send_update(data)
    data = data.merge(hostname: hostname)

    begin
      @socket.send data.to_yaml, 0, '255.255.255.255', 47357
    rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH
    end
  end

  private

  def hostname
    @hostname ||= `hostname -s`.strip
  end
end
