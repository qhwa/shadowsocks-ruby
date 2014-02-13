require 'ipaddr'
require 'socket'
require 'digest/md5'

module Shadowsocks
  class IPDetector
    GFW_LIST_PATH = File.expand_path('../../../data/gfwlist.txt', __FILE__)

    def initialize
      @internals = {}
      @nums      = []
      @dns_cache = {}
      lines = File.readlines(GFW_LIST_PATH)
      lines.each do |line|
        num = IPAddr.new(line).to_i
        @nums << num
        @internals[num.to_s] = line
      end
      @nums.sort!
    end

    def behind_gfw?(domain)
      key = Digest::MD5.hexdigest domain

      if @dns_cache[key]
        @dns_cache[key]
      else
        begin
          ip = IPSocket::getaddress(domain)

          ip_num = IPAddr.new(ip).to_i

          i = @nums.bsearch { |x| x > ip_num }
          index = @nums.index(i) - 1
          r = IPAddr.new(@internals[@nums[index].to_s]).include? ip
          if @dns_cache.size > 512
            @dns_cache.delete @dns_cache.first[0]
          end

          @dns_cache[key] = r
          r
        rescue Exception
          false
        end
      end
    end
  end
end
