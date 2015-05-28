require File.expand_path('../lib/shadowsocks/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'shadowsocks'
  s.version       = Shadowsocks::VERSION
  s.date          = Date.today
  s.summary       = "ruby version of shadowsocks"
  s.description   = "shadowsocks-ruby is a lightweight tunnel proxy which can help you get through firewalls."
  s.authors       = ["Sen"]
  s.email         = 'sen9ob@gmail.com'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/{functional,unit}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.homepage      = 'http://rubygems.org/gems/shadowsocks'
  s.license       = 'MIT'
  s.extensions    = %w[ext/encrypt/extconf.rb]

  s.add_dependency "eventmachine", "~> 1.0.3"
  s.add_dependency "json", "~> 1.8.0"
  s.add_dependency "ffi", "~> 1.9.0"

  s.add_development_dependency "rake-compiler", "~> 0.9.2"
  s.add_development_dependency "mocha", "~> 1.0.0"
  s.add_development_dependency "ipaddress", '~> 0.8.0'
  s.add_development_dependency "rake"
end
