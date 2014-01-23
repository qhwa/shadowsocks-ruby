module Shadowsocks
  module Parser
    class Server < Base
      def addr_type
        data[0]
      end

      def addr_len
        if mode == :domain
          data[1].unpack('c')[0]
        end
      end
    end
  end
end
