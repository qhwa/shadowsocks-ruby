require 'eventmachine'

module Shadowsocks
  autoload :Connection, 'shadowsocks/connection'
  autoload :Server,     'shadowsocks/server'
  autoload :Tunnel,     'shadowsocks/tunnel'
  autoload :Listener,   'shadowsocks/listener'
  autoload :IPDetector, 'shadowsocks/ip_detector'

  module Local
    autoload :Connector, 'shadowsocks/local/connector'
    autoload :Server,    'shadowsocks/local/server'
  end

  module Parsers
    #autoload :Base,     'shadowsocks/parser/base'
    autoload :Local,    'shadowsocks/parsers/local'
    autoload :Server,   'shadowsocks/parsers/server'
  end

  module Cryptos
    autoload :Wrapper,  'shadowsocks/cryptos/wrapper'
    autoload :Table,    'shadowsocks/cryptos/table'
    autoload :Openssl,  'shadowsocks/cryptos/openssl'
  end
end
