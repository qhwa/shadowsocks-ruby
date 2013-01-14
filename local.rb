#!/usr/bin/ruby

# Copyright (c) 2012 clowwindy
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'rubygems'
require 'eventmachine'
require 'json'
require './encrypt'

cfg_file = File.open('config.json')
config =  JSON.parse(cfg_file.read)
cfg_file.close

key = config['password']

$server = config['server']
$remote_port = config['server_port'].to_i
$port = config['local_port'].to_i

$encrypt_table, $decrypt_table = get_table(key)

module LocalServer
  class LocalConnector < EventMachine::Connection
    def initialize server
      @server = server
      super
    end

    def post_init
      p "connecting #{@server.remote_addr[3..-1]} via #{$server}"
      addr_to_send = @server.addr_to_send.clone
      send_data encrypt($encrypt_table, addr_to_send)

      for piece in @server.cached_pieces
        send_data encrypt($encrypt_table, piece)
      end
      @server.cached_pieces = []

      @server.stage = 5
    end

    def receive_data data
      @server.send_data encrypt($decrypt_table, data)
    end

    def unbind
      @server.close_connection_after_writing
    end
  end

  @@connected_clients = Array.new

  attr_accessor :stage, :remote_addr, :addr_to_send, :cached_pieces

  def initialize
    super
  end

  def receive_data data
    data_handler data
  end

  def post_init
    @stage = 0
    @@connected_clients.push(self)
    @cached_pieces = []
    puts "A client has connected..."
  end

  def unbind
    @@connected_clients.delete(self)
    puts "A client has left..."
  end

  private

  def data_handler data
    if @stage == 5
      @connector.send_data(encrypt($encrypt_table, data)) and return
    elsif @stage == 0
      send_data "\x05\x00"
      @stage = 1
    elsif @stage == 1
      begin
        unless data[1] == "\x01"
          send_data "\x05\x07\x00\x01"
          self.close_connection and return
        end

        @addr_to_send = data[3]

        resolve_addrtype(data)

        send_data "\x05\x00\x00\x01\x00\x00\x00\x00" + [$remote_port].pack('s>')

        @stage = 4
        @connector = EventMachine.connect $server, $remote_port, LocalConnector, self

        if data.size > @header_length
          @cached_pieces.push data[@header_length, data.size]
        end
      rescue Exception => e
        warn e
        @connector.close_connection unless @connector.nil?
        close_connection
      end
    elsif @stage == 4
      @cached_pieces.push data
    end
  end

  def resolve_addrtype(data)
    addrtype = data[3]
    if addrtype == "\x01"
      ip_address(data)
    elsif addrtype == "\x03"
      domain_adress(data)
    else
      warn "unsupported addrtype: " + addrtype.unpack('c')[0].to_s
      close_connection and return
    end
  end

  def domain_adress(data)
    addr_len = data[4].unpack('c')[0]
    @addr_to_send += data[4..5 + addr_len + 2]
    @remote_addr = data[2, addr_len]
    @remote_port = data[2 + addr_len, 2].unpack('s>')[0]
    @header_length = 2 + addr_len + 2
  end

  def ip_address(data)
    @addr_to_send += data[4..9]
    @remote_addr = inet_ntoa data[1..4]
    @remote_port = data[5, 2].unpack('s>')[0]
    @header_length = 7
  end

  def inet_ntoa(n)
    n.unpack("C*").join "."
  end

end

EventMachine::run {
  Signal.trap("INT")  { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  puts "*** Local side is up, port:#{$port}"
  puts "*** Hit Ctrl+c to stop"
  EventMachine::start_server "0.0.0.0", $port, LocalServer
}
