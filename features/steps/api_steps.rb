$:.unshift(File.expand_path('../../../lib',__FILE__))
require 'embedly'

Given /an embedly endpoint( [^\s]+)?( with ([^\s]+) key)?$/ do |endpoint, _, key|
  opts = {}
  opts[:endpoint] = endpoint
  opts[:key] = key
  @api = Embedly::API.new opts
end

When /oembed is called with the (.*) URLs?( and ([^\s]+) flag)?$/ do |urls, _, flag|
  urls = urls.split(',')
  opts = {}
  if urls.size == 1
    opts[:url] = urls.first
  else
    opts[:urls] = urls
  end
  opts[flag.to_sym] = true if flag
  @result = @api.oembed opts
end

Then /([^\s]+) should be ([^\s]+)/ do |key, value|
  if @result.is_a?Array
    @result.collect{|o| puts o.provider_url; puts key; puts o.send(key); o.send(key).to_s}.join(',').should == value
  else
    @result.send(key).to_s.should == value
  end
end

