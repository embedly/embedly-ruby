class Embedly::BadResponseException < RuntimeError
  attr_accessor :response

  def initialize response
    @response ||= response
  end
end
