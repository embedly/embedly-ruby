$:.unshift(File.expand_path('../../../lib',__FILE__))
require 'embedly'

# cache for hostnames
HOSTNAMES = {}

Given /an embedly api( with key)?$/ do |key_enabled|
  opts = {}
  if key_enabled
    raise 'Please set env variable $EMBEDLY_KEY' unless ENV['EMBEDLY_KEY']
    opts[:key] = ENV["EMBEDLY_KEY"]
    opts[:secret] = ENV["EMBEDLY_SECRET"]
  end
  if not HOSTNAMES[opts]
    HOSTNAMES[opts] = Embedly::API.new opts
  end
  @api = HOSTNAMES[opts]
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

Then /objectify api_version is (\d+)$/ do |version|
  @api.api_version[:objectify].should == version
end

Then /([^\s]+) should be (.+)$/ do |key, value|
  raise @error if @error
  @result.collect do |o|
    o.send(key).to_s
  end.join(',').should == value
end

Then /([^\s]+) should start with ([^\s]+)/ do |key, value|
  raise @error if @error
  v = key.split('.').inject(@result[0]){|o,c| o.send(c)}.to_s
  v.to_s.should match(/^#{value}/)
end
