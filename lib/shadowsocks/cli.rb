require 'optparse'
require 'pp'

require File.expand_path('../version', __FILE__)

module Shadowsocks
  class Cli
    attr_accessor :config

    def initialize(options)
      @config      = options[:config]
      @ip_detector = options[:ip_detector]
    end

    def local_up
      #connector = Shadowsocks::Local::Connector.supervise_as :connector,
                                                              #host: config.server,
                                                              #port: config.server_port

      local     = Shadowsocks::Local::Server.supervise_as :local,
                                                           host: "0.0.0.0",
                                                           port: config.local_port,
                                                           config: config,
                                                           initializer: method(:initialize_connection)

      trap("INT") { local.terminate; exit }
      sleep
    end

    def server_up
      EventMachine::run {
        Signal.trap("INT")  { EventMachine.stop }
        Signal.trap("TERM") { EventMachine.stop }

        puts "*** Server side is up, port:#{config.server_port}"
        puts "*** Hit Ctrl+c to stop"

        EventMachine::start_server "0.0.0.0", config.server_port, Shadowsocks::Server::ServerListener, &method(:initialize_connection)
      }
    end

    private

    def initialize_connection
      parser = Shadowsocks::Parsers::Local.new crypto: Shadowsocks::Cryptos::Wrapper.crypto(method: config.method, password: config.password)
      { parser: parser }
    end

    #def initialize_connection connection
      #connection.config                  = @config
      #connection.crypto                  = @crypto
      #connection.pending_connect_timeout = @config.timeout
      #connection.comm_inactivity_timeout = @config.timeout
      #connection.ip_detector             = @ip_detector if @ip_detector
    #end
  end
end
