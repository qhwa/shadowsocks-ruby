require 'eventmachine'

module Shadowsocks
  autoload :Connection, 'shadowsocks/connection'
  autoload :Server,     'shadowsocks/server'
  autoload :Local,      'shadowsocks/local'
  autoload :Tunnel,     'shadowsocks/tunnel'
  autoload :Listener,   'shadowsocks/listener'
  autoload :IPDetector, 'shadowsocks/ip_detector'

  module Parser
    autoload :Base,     'shadowsocks/parser/base'
    autoload :Local,    'shadowsocks/parser/local'
    autoload :Server,   'shadowsocks/parser/server'
  end

  module Cryptos
    autoload :Wrapper,  'shadowsocks/cryptos/wrapper'
    autoload :Table,    'shadowsocks/cryptos/table'
    autoload :Openssl,  'shadowsocks/cryptos/openssl'
  end
end
