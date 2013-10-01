require 'optparse'
require 'pp'

require File.expand_path('../version', __FILE__)

module Shadowsocks
  class Cli
    include ::Shadowsocks::Table

    attr_accessor :side, :args, :config, :table

    def initialize(options)
      @side   = options[:side]
      @config = options[:config]
      @table  = get_table(config.password)
    end

    def run
      case side
      when :local
        EventMachine::run {
          Signal.trap("INT")  { EventMachine.stop }
          Signal.trap("TERM") { EventMachine.stop }

          puts "*** Local side is up, port:#{config.local_port}"
          puts "*** Hit Ctrl+c to stop"
          EventMachine::start_server "0.0.0.0", config.local_port, Shadowsocks::Local::LocalListener, &method(:initialize_connection)
        }
      when :server
        EventMachine::run {
          Signal.trap("INT")  { EventMachine.stop }
          Signal.trap("TERM") { EventMachine.stop }

          puts "*** Server side is up, port:#{config.server_port}"
          puts "*** Hit Ctrl+c to stop"

          EventMachine::start_server "0.0.0.0", config.server_port, Shadowsocks::Server::ServerListener, &method(:initialize_connection)
        }
      end
    end

    private

    def initialize_connection connection
      connection.config                  = @config
      connection.table                   = @table
      connection.pending_connect_timeout = @config.timeout
    end

  end
end
