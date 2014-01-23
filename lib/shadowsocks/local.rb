module Shadowsocks
  module Local
    class ServerConnector < ::Shadowsocks::Tunnel
      def post_init
        p "connecting #{server.remote_addr[3..-1]} via #{server.config.server}"
        addr_to_send = server.addr_to_send.clone

        send_data encrypt(addr_to_send)
        server.cached_pieces.each { |piece| send_data encrypt(piece) }
        server.cached_pieces = []

        server.stage = 5
      end

      def receive_data data
        server.send_data decrypt(data)
        outbound_scheduler
      end
    end

    class LocalListener < ::Shadowsocks::Listener
      private

      def data_handler data
        case stage
        when 0
          send_data "\x05\x00"
          @stage = 1
        when 1
          fireup_tunnel data
        when 4
          cached_pieces.push data
        when 5
          connector.send_data(encrypt(data)) and return
        end
      end

      def fireup_tunnel(data)
        begin
          unless data[1] == "\x01"
            send_data "\x05\x07\x00\x01"
            connection_cleanup and return
          end

          parse_data Shadowsocks::Parser::Local.new(data)

          send_data "\x05\x00\x00\x01\x00\x00\x00\x00" + [config.server_port].pack('s>')

          @stage = 4
          @connector = EventMachine.connect config.server, config.server_port, ServerConnector, self, crypto

          if data.size > header_length
            cached_pieces.push data[header_length, data.size]
          end
        rescue Exception => e
          warn e
          connection_cleanup
        end
      end
    end
  end
end
