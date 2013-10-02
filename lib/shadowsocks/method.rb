require 'openssl'

module Shadowsocks
  class Method
    include ::Shadowsocks::Table

    attr_accessor :encrypt_table, :decrypt_table, :password, :method

    def initialize(options = {})
      @password = options[:password]
      @method   = options[:method]

      unless %w(talbe bf-cfb aes-256-cfb des-cfb).include?(method)
        raise "Encrypt method not support"
      end

      if method == 'table'
        generate_table
      end
    end

    def encrypt buf
      case method
      when 'table'
        calculate encrypt_table, buf
      when 'bf-cfb'
      when 'aes-256-cfb'
      when 'des-cfb'
        cipher = OpenSSL::Cipher.new method.upcase
        
      end
    end

    def decrypt buf
      case method
      when 'table'
        calculate decrypt_table, buf        
      when 'bf-cfb'
      when 'aes-256-cfb'
      when 'des-cfb'
      end
    end

    private

    def generate_table
      @encrypt_table, @decrypt_table = get_table password      
    end
  end
end
