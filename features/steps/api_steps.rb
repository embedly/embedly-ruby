$:.unshift(File.expand_path('../../../lib',__FILE__))
require 'embedly'

# cache for endpoints
ENDPOINTS = {}

Given /an embedly endpoint( [^\s]+)?( with key)?$/ do |endpoint, key_enabled|
  opts = {}
  opts[:endpoint] = endpoint
  if key_enabled
    raise 'Please set env variable $EMBEDLY_KEY' unless ENV['EMBEDLY_KEY']
    opts[:key] = ENV["EMBEDLY_KEY"] 
  end
  if not ENDPOINTS[opts]
    ENDPOINTS[opts] = Embedly::API.new opts
  end
  @api = ENDPOINTS[opts]
end

When /(\w+) is called with the (.*) URLs?( and ([^\s]+) flag)?$/ do |method, urls, _, flag|
  @result = nil
  begin
    urls = urls.split(',')
    opts = {}
    if urls.size == 1
      opts[:url] = urls.first
    else
      opts[:urls] = urls
    end
    opts[flag.to_sym] = true if flag
    @result = @api.send(method, opts)
  rescue
    @error = $!
  end
end

Then /an? (\w+) error should get thrown/ do |error|
  @error.class.to_s.should == error
end

Then /([^\s]+) should be (.+)$/ do |key, value|
  raise @error if @error
  logger = Embedly.logger('api_steps')
  @result.collect do |o|  
    logger.debug { "result: #{o.marshal_dump}"}
    o.send(key).to_s
  end.join(',').should == value
end

Then /([^\s]+) should start with ([^\s]+)/ do |key, value|
  raise @error if @error
  logger = Embedly.logger('api_steps')
  logger.debug { "result: #{@result[0].marshal_dump}"}
  v = key.split('.').inject(@result[0]){|o,c| o.send(c)}.to_s
  v.to_s.should match(/^#{value}/)
end

