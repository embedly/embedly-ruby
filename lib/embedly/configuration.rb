require 'logger'

class Embedly::Configuration
  attr_accessor :key

  def initialize
    self.reset
  end

  def debug?
    self.logger.debug?
  end

  def debug=(true_or_false)
    set_logger_level(true_or_false)
  end

  def logger
    @logger ||= default_logger
  end

  def logger=(log)
    @logger = log
    set_logger_level(self.debug?)
  end

  def reset
    self.logger = default_logger
    self.debug  = false
  end

  private

  def default_logger
    Logger.new(STDERR)
  end

  def set_logger_level(true_or_false)
    logger.level = true_or_false ? Logger::DEBUG : Logger::ERROR
  end
end
