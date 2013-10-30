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
        server.send_data encrypt(table[:encrypt_table], data)
        outbound_checker
      end
    end

    class ServerListener < ::Shadowsocks::Listener
      private

      def data_handler data
        data = encrypt table[:decrypt_table], data
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
          resolve_addrtype data

          @stage = 4

          if data.size > header_length
            cached_pieces.push data[header_length, data.size]
          end

          @connector = EventMachine.connect @remote_addr, @remote_port, RequestConnector, self, table
        rescue Exception => e
          warn e
          connection_cleanup
        end
      end

      def resolve_addrtype data
        @addrtype = data[0]
        super
      end

      def domain_address data
        @addr_len = data[1].unpack('c')[0]
        super
      end
    end
  end
end

