module Embedly
  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end

require 'embedly/api'
