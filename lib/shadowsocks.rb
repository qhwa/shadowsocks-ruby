require 'eventmachine'

module Shadowsocks
  autoload :Crypto,   'shadowsocks/crypto'
  autoload :Connection, 'shadowsocks/connection'
  autoload :Server,     'shadowsocks/server'
  autoload :Local,      'shadowsocks/local'
  autoload :Table,      'shadowsocks/table'
  autoload :Tunnel,     'shadowsocks/tunnel'
  autoload :Listener,   'shadowsocks/listener'
end
