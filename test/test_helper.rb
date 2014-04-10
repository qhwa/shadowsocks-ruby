require "bundler/setup"
require "minitest/autorun"

Dir[File.expand_path('../support/**/*', __FILE__)].each &method(:require)
