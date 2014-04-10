require 'test_helper'
require_relative '../../lib/shadowsocks/cryptos/table'

class TestTable < Minitest::Test
  def test_encrypt
    table = Shadowsocks::Cryptos::Table.new password: 'iamkey'
    assert_equal table.encrypt("abcd").dump, "\"$\\x9C\\xAB\\x94\""
  end

  def test_decrypt
    table = Shadowsocks::Cryptos::Table.new password: 'iamkey'
    assert_equal table.decrypt("$\x9C\xAB\x94"), "abcd"
  end
end
