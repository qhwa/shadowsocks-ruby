module Shadowsocks
  module Server
    class RequestConnector < ::Shadowsocks::Tunnel
      def post_init
        p "connecting #{server.remote_addr} via #{server.config.server}"

        server.cached_pieces.each { |piece| send_data piece }
        server.cached_pieces = nil

        server.stage = 5
      end

      def receive_data data
        server.send_data encrypt(data)
        outbound_scheduler
      end
    end

    class ServerListener < ::Shadowsocks::Listener
      private

      def data_handler data
        data = decrypt data
        case stage
        when 0
          fireup_tunnel data
        when 4
          cached_pieces.push data
        when 5
          connector.send_data(data) and return
        end
      end

      def fireup_tunnel data
        begin
          parse_data Shadowsocks::Parser::Server.new(data)

          @stage = 4

          if data.size > header_length
            cached_pieces.push data[header_length, data.size]
          end

          @connector = EventMachine.connect @remote_addr, @remote_port, RequestConnector, self, crypto
        rescue Exception => e
          warn e
          connection_cleanup
        end
      end
    end
  end
end

