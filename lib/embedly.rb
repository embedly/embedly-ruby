require 'logger'
require 'ostruct'

module Embedly
  VERSION = File.read(File.expand_path('../../VERSION', __FILE__))
  Config = OpenStruct.new

  def self.logger(name)
    @_loggers ||= {}
    logger = @_loggers[name] ||= Logger.new(STDOUT)
    logger.level = Embedly::Config.logging ? Logger::DEBUG : Logger::ERROR
    logger
  end
end

require 'embedly/api'
