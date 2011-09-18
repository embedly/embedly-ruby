require 'logger'

# Configure the api
#
# === Available settings
#
# * [+debug+] Prints debugging information to logger. Default +false+. Errors still will be logged
# * [+logger+] Configure the logger; set this if you want to use a custom logger.
#
# === Usage
#
#   Embedly.configure do |config|
#     # prints debug messages
#     config.debug = true
#
#     # customize the logger
#     config.logger = MyAwesomeLogger.new(STDERR)
#   end
#
class Embedly::Configuration
  attr_accessor :key, :requester # :nodoc:

  def initialize # :nodoc:
    self.reset
  end

  def debug? # :nodoc:
    self.logger.debug?
  end

  def debug=(true_or_false) # :nodoc:
    set_logger_level(true_or_false)
  end

  def logger # :nodoc:
    @logger ||= default_logger
  end

  def logger=(log) # :nodoc:
    @logger = log
    set_logger_level(self.debug?)
  end

  def add_requester(name, &block)
    requesters[name] = block
  end

  def requesters
    @requesters ||= {}
  end

  def request_with(adapter_name)
    self.requester = adapter_name
  end

  def current_requester
    requesters[requester]
  end

  # reset configuration
  def reset
    self.logger   = default_logger
    self.debug    = false
    self.request_with :typhoeus
  end

  private

  def default_logger # :nodoc:
    Logger.new(STDERR)
  end

  def set_logger_level(true_or_false) # :nodoc:
    logger.level = true_or_false ? Logger::DEBUG : Logger::ERROR
  end
end
