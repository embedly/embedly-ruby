require 'logger'

# Configure the api
#
# === Available settings
#
# * [+debug+] Prints debugging information to logger. Default +false+. Errors still will be logged
# * [+logger+] Configure the logger; set this if you want to use a custom logger.
# * [+request_with+] Sets the desired library to perform requests. Default is +Typhoeus+
#
# === Usage
#
#   Embedly.configure do |config|
#     # prints debug messages
#     config.debug = true
#
#     # customize the logger
#     config.logger = MyAwesomeLogger.new(STDERR)
#
#     # performs requests with net/http
#     config.request_with :net_http
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

  # Configures a new requester
  #
  # To add a new requester class, you can do the following:
  #
  #    Embedly.configuration.add_requester :custom do |api|
  #      MyRequester.new(api)
  #    end
  #
  # The requester class should respond to +get+ method, which performs the request
  # for more details, see +embedly/request/base.rb+
  def add_requester(name, &block)
    requesters[name] = block
  end

  def requesters # :nodoc:
    @requesters ||= {}
  end

  # Sets api to use the desired requester class
  #
  # When configuring the API, you can do the following:
  #
  #    Embedly.configure do |config|
  #      config.request_with :net_http
  #    end
  #
  # This way, the API will use the +net_http+ class to perform requests
  def request_with(adapter_name)
    self.requester = adapter_name
  end

  # Returns the current configured request block
  def current_requester
    requesters[requester]
  end

  # reset configuration
  def reset
    self.logger   = default_logger
    self.debug    = false
    self.request_with :net_http
  end

  private

  def default_logger # :nodoc:
    Logger.new(STDERR)
  end

  def set_logger_level(true_or_false) # :nodoc:
    logger.level = true_or_false ? Logger::DEBUG : Logger::ERROR
  end
end

# Use typhoeus by default if it is installed
begin
  require "typhoeus"
  Embedly.configuration.request_with :typhoeus
rescue LoadError
  Embedly.configuration.request_with :net_http
end
