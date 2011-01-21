require 'logger'
require 'ostruct'

module Embedly
  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip
  Config = OpenStruct.new

  def self.logger(name)
    @_loggers ||= {}
    logging = Embedly::Config.logging
    logger = @_loggers[name] ||= Logger.new(STDERR)
    logger.level = logging ? Logger::DEBUG : Logger::ERROR
    logger
  end
end

require 'embedly/api'
