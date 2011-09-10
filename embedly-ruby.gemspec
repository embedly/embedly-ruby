# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "embedly/version"

Gem::Specification.new do |s|
  s.name        = "embedly-ruby"
  s.version     = Embedly::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["embedly"]
  s.email       = ["support@embed.ly"]
  s.homepage    = %q{http://github.com/embedly/embedly-ruby}
  s.summary     = "Ruby Embedly Client"
  s.description = "Embedly ruby client library. To find out what Embedly is all about, please visit embed.ly. To see our api documentation, visit api.embed.ly/docs."

  s.add_dependency("querystring", ">= 0.1.0")

  s.files        = Dir.glob("lib/**/*") + %w(README.rdoc Rakefile)
  s.require_path = 'lib'
end
