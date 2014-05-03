require 'test_helper'
require_relative '../../lib/shadowsocks/cryptos/openssl'

class TestOpenssl < Minitest::Test
  def test_encrypt_and_decrypt
    crypto = Shadowsocks::Cryptos::Openssl.new password: 'iamkey', method: 'aes-128-cfb'
    str = "abcd"
    str_2 = "defg"
    encrypted = crypto.encrypt(str)
    refute_equal str, encrypted
    assert_equal crypto.decrypt(encrypted), str
    encrypted = crypto.encrypt(str_2)
    refute_equal str_2, encrypted
    assert_equal crypto.decrypt(encrypted), str_2
  end
end
