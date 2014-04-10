require 'test_helper'
require_relative '../../lib/shadowsocks/cryptos/table'
require_relative '../../lib/shadowsocks/cryptos/openssl'
require_relative '../../lib/shadowsocks/cryptos/wrapper'

class TestWrapper < Minitest::Test
  def test_wrapper_with_table
    crypto = Shadowsocks::Cryptos::Wrapper.crypto method: 'table', password: 'password'
    assert_respond_to crypto, :encrypt
    assert_respond_to crypto, :decrypt
  end

  def test_wrapper_with_openssl
    crypto = Shadowsocks::Cryptos::Wrapper.crypto method: 'aes-128-cfb', password: 'password'
    assert_respond_to crypto, :encrypt
    assert_respond_to crypto, :decrypt
  end
end

