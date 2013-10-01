task :gem do
  `gem build ./shadowsocks.gemspec`
end

task :install do
  `gem install ./shadowsocks-#{Shadowsocks::VERSION}.gem`
end
