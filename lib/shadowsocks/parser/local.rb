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
    end
  end
end
