require 'ipaddr'
require 'socket'

module Shadowsocks
  class IPDetector
    GFW_LIST_PATH = './data/gfwlist.txt'

    def initialize
      @internals = {}
      @nums      = []
      lines = File.readlines(GFW_LIST_PATH)
      lines.each do |line|
        num = IPAddr.new(line).to_i
        @nums << num
        @internals[num.to_s] = line
      end
      @nums.sort!
    end

    def behind_gfw?(domain)
      ip = IPSocket::getaddress(domain)

      ip_num = IPAddr.new(ip).to_i

      i = @nums.bsearch { |x| x > ip_num }
      index = @nums.index(i) - 1
      IPAddr.new(@internals[@nums[index].to_s]).include? ip
    end
  end
end
