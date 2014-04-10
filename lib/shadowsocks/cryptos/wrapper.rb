module Shadowsocks
  module Cryptos
    class Wrapper
      def self.crypto(options = {})
        method   = options.fetch(:method, 'aes-128-cfb')
        password = options.fetch(:password)

        if method == 'table'
          Shadowsocks::Cryptos::Table.new password: password
        else
          Shadowsocks::Cryptos::Openssl.new method: method, password: password
        end
      end
    end
  end
end
