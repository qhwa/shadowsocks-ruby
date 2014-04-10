require 'test_helper'
require_relative '../../lib/shadowsocks/cryptos/openssl'

class TestOpenssl < Minitest::Test
  def test_encrypt_and_
    crypto = Shadowsocks::Cryptos::Openssl.new password: 'iamkey', method: 'aes-128-cfb'
    str = "abcd"
    encrypted = crypto.encrypt(str)
    refute_equal str, encrypted
    assert_equal crypto.decrypt(encrypted), str
  end
end
