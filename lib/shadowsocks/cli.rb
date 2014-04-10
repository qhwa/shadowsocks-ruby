require 'optparse'
require 'pp'

require File.expand_path('../version', __FILE__)

module Shadowsocks
  class Cli
    attr_accessor :config

    def initialize(options)
      @config      = options[:config]
      @crypto      = options[:crypto]
      @ip_detector = options[:ip_detector]
    end

    def local_up
      EventMachine::run {
        Signal.trap("INT")  { EventMachine.stop }
        Signal.trap("TERM") { EventMachine.stop }

        puts "*** Local side is up, port:#{config.local_port}"
        puts "*** Hit Ctrl+c to stop"
        EventMachine::start_server "0.0.0.0", config.local_port, Shadowsocks::Local::LocalListener, &method(:initialize_connection)
      }
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

    def initialize_connection connection
      connection.config                  = @config
      connection.crypto                  = @crypto
      connection.pending_connect_timeout = @config.timeout
      connection.comm_inactivity_timeout = @config.timeout
      connection.ip_detector             = @ip_detector if @ip_detector
    end
  end
end
