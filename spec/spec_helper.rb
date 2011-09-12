require "embedly"

RSpec.configure do |config|
  config.after do
    Embedly.configuration.reset
  end
end
