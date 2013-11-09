require 'securerandom'
require 'openssl'
require 'digest/md5'

module Shadowsocks
  class Crypto
    include ::Shadowsocks::Table

    attr_accessor :encrypt_table, :decrypt_table, :password, :method,
                  :cipher, :bytes_to_key_results, :iv_sent

    def method_supported
      case method
      when 'aes-128-cfb'      then [16, 16]
      when 'aes-192-cfb'      then [24, 16]
      when 'aes-256-cfb'      then [32, 16]
      when 'bf-cfb'           then [16, 8 ]
      when 'camellia-128-cfb' then [16, 16]
      when 'camellia-192-cfb' then [24, 16]
      when 'camellia-256-cfb' then [32, 16]
      when 'cast5-cfb'        then [16, 8 ]
      when 'des-cfb'          then [8,  8 ]
      when 'idea-cfb'         then [16, 8 ]
      when 'rc2-cfb'          then [16, 8 ]
      when 'rc4'              then [16, 0 ]
      when 'seed-cfb'         then [16, 16]
      end
    end
    alias_method :get_cipher_len, :method_supported

    def initialize(options = {})
      @password = options[:password]
      @method   = options[:method].downcase
      @iv_sent  = false
      if method == 'table'
        @encrypt_table = options[:encrypt_table]
        @decrypt_table = options[:decrypt_table]
      else
        if method_supported.nil?
          raise "Encrypt method not support"
        end
      end

      if method != 'table'
        @cipher = get_cipher(1, SecureRandom.hex(32))
      end
    end

    def encrypt buf
      return buf if buf.length == 0
      if method == 'table'
        translate @encrypt_table, buf
      else
        if iv_sent
          @cipher.update(buf)
        else
          @iv_sent = true
          @cipher_iv + @cipher.update(buf)
        end
      end
    end

    def decrypt buf
      return buf if buf.length == 0
      if method == 'table'
        translate @decrypt_table, buf
      else
        if @decipher.nil?
          decipher_iv_len = get_cipher_len[1]
          decipher_iv     = buf[0..decipher_iv_len ]
          @iv             = decipher_iv
          @decipher       = get_cipher(0, @iv)
          buf             = buf[decipher_iv_len..-1]
          return buf if buf.length == 0
        end
        @decipher.update(buf)
      end
    end

    private

    def iv_len
      @cipher_iv.length
    end

    def get_cipher(op, iv)
      m = get_cipher_len
      unless m.nil?
        key, _iv   = EVP_BytesToKey(m[0], m[1])

        iv         = _iv[0..m[1] - 1]
        @iv        = iv unless @iv
        @cipher_iv = iv if op == 1

        cipher = OpenSSL::Cipher.new method

        op == 1 ? cipher.encrypt : cipher.decrypt

        cipher.key = key
        cipher.iv  = @iv
        cipher
      end
    end

    def EVP_BytesToKey key_len, iv_len
      if bytes_to_key_results
        return bytes_to_key_results
      end

      m = []
      i = 0

      len = key_len + iv_len

      code = password.unpack('H*').first

      while m.join.length < len do
        data = if i > 0
                 m[i - 1] + password
               else
                 password
               end
        m.push Digest::MD5.digest data
        i += 1
      end
      ms  = m.join
      key = ms[0, key_len]
      iv  = ms[key_len, key_len + iv_len]
      bytes_to_key_results = [key, iv]
      bytes_to_key_results
    end
  end
end
