require 'celluloid/io'


module Shadowsocks
  module Local
    class Server
      include Celluloid::IO
      finalizer :finalize

      attr_reader :state, :config, :initializer

      def initialize(options = {})
        host            = options.fetch(:host)
        port            = options.fetch(:port)
        @config         = options.fetch(:config)
        @initializer    = options.fetch(:initializer)

        puts "*** Starting local side on #{host}:#{port}"

        @server = TCPServer.new(host, port)
        async.run
      end

      def finalize
        @server.close if @server
      end

      def run
        loop { async.handle_connection @server.accept }
      end

      def handle_connection(socket)
        _, port, host = socket.peeraddr
        #puts "*** Received connection from #{host}:#{port}"

        parser = initializer.call[:parser]
        connector = Connector.new host: config.server,
                                  port: config.server_port,
                                  local_socket: socket,
                                  parser: parser
        loop do
          if socket.closed?
            raise EOFError
            break
          else
            data_handler(socket, parser, connector)
          end
        end
      rescue EOFError
        #puts "*** #{host}:#{port} disconnected"
        connector.cleanup_and_terminate if connector.alive?
        socket.close unless socket.closed?
      end

      def receive_remote_data(socket, parser, data)
        socket.write handle_databack(data, parser) unless socket.closed?
      end

      private

      def handle_data(data, parser)
        parser.handle(data, config.server_port)
      end

      def handle_databack(data, parser)
        parser.handle_databack(data)
      end

      def next_state(parser)
        parser.next_state
      end

      def data_handler(socket, parser, connector)
        raw = socket.readpartial(4096)

        data = handle_data(raw, parser)

        to_send = data.fetch(:to_send, nil)
        state   = data.fetch(:state)
        if _error = data.fetch(:error, nil)
          socket.write to_send if to_send
          socket.close
        else
          case state
          when :connected
            push_data(connector, socket, data[:to_send])
          when :init, :connecting
            socket.write to_send
            next_state(parser)
            push_data(connector, socket, data[:addr_to_send]) if state == :connecting
          end
        end
      end

      def push_data(connector, socket, data)
        if connector.alive?
          connector.push_data data
        else
          socket.close unless socket.closed?
        end
      end

    end
  end
end
