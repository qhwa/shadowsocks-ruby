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

    class DirectConnector < ::Shadowsocks::Tunnel
      def post_init
        p "connecting #{server.remote_addr[3..-1]} directly"
        server.cached_pieces.each { |piece| send_data piece }
        server.cached_pieces = []

        server.stage = 5
      end

      def receive_data data
        server.send_data data
        outbound_scheduler
      end
    end

    class LocalListener < ::Shadowsocks::Listener
      attr_accessor :behind_gfw

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
          to_send = \
            if behind_gfw
              data
            else
              encrypt(data)
            end
          connector.send_data(to_send) and return
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

          if config.chnroutes
            @behind_gfw = @ip_detector.behind_gfw?(@remote_addr[3..-1])
          end

          if config.chnroutes == true and behind_gfw
            @connector = EventMachine.connect @remote_addr[3..-1], @remote_port, DirectConnector, self, crypto
          else
            @connector = EventMachine.connect config.server, config.server_port, ServerConnector, self, crypto
          end

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
