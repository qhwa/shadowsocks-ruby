module Shadowsocks
  module Parser
    class Local < Base
      def addr_type
        data[3]
      end

      def addr_len
        if mode == :domain
          data[4].unpack('c')[0]
        end
      end

      def remote_addr
        case mode
        when :domain
          data[2, addr_len + 3]
        when :ip
          inet_ntoa data[1..4]
        end
      end

      def remote_port
        case mode
        when :domain
          data[5 + addr_len, 2].unpack('s>')[0]
        when :ip
          data[5, 2].unpack('s>')[0]
        end
      end
    end
  end
end
