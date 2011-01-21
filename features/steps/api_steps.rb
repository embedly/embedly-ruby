$:.unshift(File.expand_path('../../../lib',__FILE__))
require 'embedly'

Given /an embedly endpoint( [^\s]+)?( with key)?$/ do |endpoint, key_enabled|
  opts = {}
  opts[:endpoint] = endpoint
  if key_enabled
    raise 'Please set env variable $EMBEDLY_KEY' unless ENV['EMBEDLY_KEY']
    opts[:key] = ENV["EMBEDLY_KEY"] 
  end
  @api = Embedly::API.new opts
end

When /(\w+) is called with the (.*) URLs?( and ([^\s]+) flag)?$/ do |method, urls, _, flag|
  urls = urls.split(',')
  opts = {}
  if urls.size == 1
    opts[:url] = urls.first
  else
    opts[:urls] = urls
  end
  opts[flag.to_sym] = true if flag
  @result = @api.send(method, opts)
end

Then /([^\s]+) should be ([^\s]+)/ do |key, value|
  logger = Embedly.logger('api_steps')
  if @result.is_a?Array
    @result.collect do |o|  
      logger.debug { "result: #{o.marshal_dump}"}
      o.send(key).to_s
    end.join(',').should == value
  else
    logger.debug { "result: #{@result.marshal_dump}"}
    @result.send(key).to_s.should == value
  end
end

