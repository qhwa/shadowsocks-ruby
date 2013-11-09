module Shadowsocks
  class Tunnel < ::Shadowsocks::Connection
    attr_accessor :server

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
  end
end
