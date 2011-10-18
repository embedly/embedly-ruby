class Embedly::BadResponseException < RuntimeError
  attr_accessor :response, :path

  def initialize(response, path = nil)
    @response ||= response
    @path ||= path
  end

  def message
    "Bad Response : #{@response.inspect} for path: #{@path.inspect}"
  end

  def inspect
    self.message
  end

  def to_s
    self.message
  end
end
