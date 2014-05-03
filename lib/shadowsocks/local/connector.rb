require 'celluloid/io'

module Shadowsocks
  module Local
    class Connector
      include Celluloid::IO
      finalizer :finalize

      def initialize(options = {})
        host          = options.fetch(:host)
        port          = options.fetch(:port)
        @local_socket = options.fetch(:local_socket)
        @parser       = options.fetch(:parser)

        #puts "*** Starting local connector server on #{host}:#{port}"

        @socket = TCPSocket.new(host, port)

        async.run_connector
      rescue Errno::ECONNREFUSED
        cleanup_and_terminate
      end

      def finalize
        cleanup
      end

      def run_connector
        loop do
          if @socket.closed?
            break
          else
            handle_data
          end
        end
      rescue Errno::ECONNRESET
      rescue EOFError
        cleanup_and_terminate
      end

      def push_data(data)
        @socket.write data unless @socket.closed?
      end

      def cleanup_and_terminate
        cleanup
        async.terminate
      end

      private

      def handle_data
        data = @socket.readpartial(4096)
        local.receive_remote_data @local_socket, @parser, data if local
      end

      def local
        Celluloid::Actor[:local]
      end

      def cleanup
        @socket.close if !@socket.closed?
      end

    end
  end
end
