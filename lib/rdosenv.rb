#
# Use bundler to load dependencies
#

ENV['BUNDLE_GEMFILE'] ||= ::File.expand_path(::File.join(::File.dirname(__FILE__), "..", "Gemfile"))
begin
  require 'bundler/setup'
rescue ::LoadError
  $stderr.puts "[*] Rdos requires the Bundler gem to be installed"
  $stderr.puts "    $ gem install bundler"
  exit(0)
end

module RDOS
    Version = "v 0.01"
end
