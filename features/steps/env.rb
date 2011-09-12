require 'aruba/cucumber'
require 'embedly'

Before do
  @aruba_timeout_seconds = 15
end

Embedly.configure do |config|
  config.debug = !!ENV["EMBEDLY_VERBOSE"]
end
