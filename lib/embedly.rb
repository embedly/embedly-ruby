require 'logger'

module Embedly
  VERSION = File.read(File.expand_path('../../VERSION', __FILE__))

  def self.logger(name)
    @_loggers ||= {}
    @_loggers[name] ||= Logger.new(STDOUT)
    @_loggers[name].level = Logger::ERROR
    @_loggers[name]
  end
end

require 'embedly/api'
