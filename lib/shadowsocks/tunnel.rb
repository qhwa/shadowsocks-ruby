module Shadowsocks
  class Tunnel < ::Shadowsocks::Connection
    attr_accessor :server, :table

    def initialize server, crypto
      @server = server
      @crypto = crypto
      super
    end

    def unbind
      server.close_connection_after_writing
    end

    def remote
      server
    end

    private

    def encrypt(buf)
      crypto.encrypt(buf)
    end

    def decrypt(buf)
      crypto.decrypt(buf)
    end
  end
end
