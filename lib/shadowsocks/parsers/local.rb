module Shadowsocks
  module Parsers
    class Local
      attr_reader :state

      STATES = [:init, :connecting, :connected]

      def initialize(options = {})
        @crypto = options.fetch(:crypto)
        @state = :init
      end

      def next_state
        index = STATES.index state
        if index < STATES.count - 1
          @state = STATES[index + 1]
        end
      end

      def handle(data, port)
        case state
        when :init
          { state: state, to_send: "\x05\x00" }
        when :connecting
          handle_connecting(data, port)
        when :connected
          { state: state, to_send: encrypt(data) }
        end
      end

      def handle_databack(data)
        decrypt(data)
      end

      private

      def handle_connecting(data, port)
        cmd = data[1]
        address_type = data[3]

        if cmd != "\x01"
          { error: "unsupported CMD: #{cmd}", to_send: "\x05\x07\x00\x01" }
        else
          data = \
            case address_type
            when "\x01"
              resolve_ip(data)
            when "\x03"
              resolve_domain(data)
            else
              { error: "unsupported address type: #{address_type.unpack('c')[0]}" }
            end

          if data.fetch(:error, nil)
            data
          else
            {
              state: state,
              data: data,
              addr_to_send: encrypt(@addr_to_send),
              to_send: "\x05\x00\x00\x01\x00\x00\x00\x00" + [port].pack('s>')
            }
          end
        end
      end

      def resolve_ip(data)
        h = {}
        @addr_to_send  = h[:addr_to_send]  = data[3..9]
        @remote_addr   = h[:remote_addr]   = inet_ntoa data[4..7]
        @remote_port   = h[:remote_port]   = data[8, 2].unpack('s>')[0]
        @header_length = h[:header_length] = 10
        h
      end

      def resolve_domain(data)
        h = {}
        addr_len       = data[4].unpack('c')[0]
        @addr_to_send  = h[:addr_to_send]  = data[3..5 + addr_len + 2]
        @remote_addr   = h[:remote_addr]   = data[5, addr_len]
        @remote_port   = h[:remote_port]   = data[5 + addr_len, 2].unpack('s>')[0]
        @header_length = h[:header_length] = 5 + addr_len + 2
        h
      end

      def encrypt(buf)
        @crypto.encrypt buf
      end

      def decrypt(buf)
        @crypto.decrypt buf
      end

      def inet_ntoa(n)
        n.unpack("C*").join "."
      end
    end
  end
end
