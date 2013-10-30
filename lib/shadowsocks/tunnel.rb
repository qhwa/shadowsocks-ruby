module Shadowsocks
  class Tunnel < ::Shadowsocks::Connection
    attr_accessor :server, :table

    def initialize server, table
      @server = server
      @table  = table
      super
    end

    def unbind
      server.close_connection_after_writing
    end

    def remote
      server
    end

    def encrypt table, data
      server.encrypt table, data
    end
  end
end
