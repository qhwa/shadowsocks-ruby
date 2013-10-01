module Shadowsocks
  class Listener < EventMachine::Connection
    include ::Shadowsocks::Table

    attr_accessor :stage, :remote_addr, :remote_port, :addr_to_send, :cached_pieces,
                  :header_length, :connector, :config, :table

    def receive_data data
      data_handler data
    end

    def post_init
      @stage = 0
      @cached_pieces = []
      puts "A client has connected..."
    end

    def unbind
      puts "A client has left..."
      connection_cleanup
    end

    private

    def connection_cleanup
      connector.close_connection if connector
      self.close_connection
    end

    def resolve_addrtype data
      case @addrtype
      when "\x01"
        ip_address data
      when "\x03"
        domain_address data
      else
        warn "unsupported addrtype: " + @addrtype.unpack('c')[0].to_s
        connection_cleanup
      end
    end

    def domain_address data
      @remote_addr   = data[2, @addr_len]
      @remote_port   = data[2 + @addr_len, 2].unpack('s>')[0]
      @header_length = 2 + @addr_len + 2
    end

    def ip_address data
      @remote_addr   = inet_ntoa data[1..4]
      @remote_port   = data[5, 2].unpack('s>')[0]
      @header_length = 7
    end

    def inet_ntoa n
      n.unpack("C*").join "."
    end
  end
end
