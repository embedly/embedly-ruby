require 'net/http'
require 'json'
require 'ostruct'
require 'embedly/model'
require 'querystring'


# Performs api calls to embedly.
#
# You won't find methods.  We are using method_missing and passing the method
# name to apicall.
#
# === Currently Supported Methods
#
# * +oembed+
# * +objectify+
# * +preview+ _pro-only_
#
# All methods return ostructs, so fields can be accessed with the dot operator. ex.
#
#   api = Embedly::API.new
#   obj = api.oembed :url => 'http://blog.doki-pen.org/'
#   puts obj[0].title, obj[0].description, obj[0].thumbnail_url
#
# Call parameters should be passed as the opts parameter.  If set, key will
# automatically be added to the query string of the call, so no need to set it.
#
# This API _would_ be future compatible, if not for the version.  In order to
# add support for a new method, you will need to add a version to the
# api_version hash.  Here is an example.
#
#   api = Embedly::API.new
#   api.api_version[:new_method] = 3
#   api.new_method :arg1 => '1', :arg2 => '2'
#
class Embedly::API
  attr_reader :key, :hostname, :api_version, :user_agent

  def logger *args
    Embedly.logger *args
  end

  # === Options
  #
  # [:+hostname+] Hostname of embedly server.  Defaults to api.embed.ly if no key is provided, pro.embed.ly if key is provided.
  # [:+key+] Your pro.embed.ly api key.
  # [:+user_agent+] Your User-Agent header.  Defaults to Mozilla/5.0 (compatible; embedly-ruby/VERSION;)
  def initialize opts={}
    @endpoints = [:oembed, :objectify, :preview]
    @key = opts[:key]
    @api_version = Hash.new('1')
    @api_version.merge!({:objectify => '2'})
    @hostname = opts[:hostname] || 'api.embed.ly'
    @user_agent = opts[:user_agent] || "Mozilla/5.0 (compatible; embedly-ruby/#{Embedly::VERSION};)"
    @referrer = opts[:referrer]
  end

  # <b>Use methods oembed, objectify, preview in favor of this method.</b>
  #
  # Normalizes url and urls parameters and calls the endpoint.  url OR urls
  # must be present
  #
  # === Options
  #
  # [:+url+] _(optional)_ A single url
  # [:+urls+] _(optional)_ An array of urls
  # [:+action+] The method that should be called. ex. oembed, objectify, preview
  # [:+version+] The api version number.
  # [_others_] All other parameters are used as query strings.
  def apicall opts
    opts[:urls] ||= []
    opts[:urls] << opts[:url] if opts[:url]

    raise 'must pass urls' if opts[:urls].size == 0

    params = {:urls => opts[:urls]}

    # store unsupported services as errors and don't send them to embedly
    rejects = []
    if not key
      params[:urls].reject!.with_index do |url, i| 
        if url !~ services_regex
          rejects << [i, 
            Embedly::EmbedlyObject.new(
              :type => 'error', 
              :error_code => 401, 
              :error_message => 'This service requires an Embedly Pro account'
            )
          ]
        end
      end
    end

    if params[:urls].size > 0
      params[:key] = key if key
      params.merge!Hash[
        opts.select{|k,_| not [:url, :urls, :action, :version].index k}
      ]

      path = "/#{opts[:version]}/#{opts[:action]}?#{QueryString.stringify(params)}"

      logger.debug { "calling #{hostname}#{path}" }

      host, port = uri_parse(hostname)
      response = Net::HTTP.start(host, port) do |http|
        http.get(path, {'User-Agent' => user_agent})
      end

      if response.code.to_i == 200
        logger.debug { response.body }
        # [].flatten is to be sure we have an array
        objs = [JSON.parse(response.body)].flatten.collect do |o| 
          Embedly::EmbedlyObject.new(o)
        end
      else
        logger.error { response.inspect }
        raise 'An unexpected error occurred'
      end

      # re-insert rejects into response
      rejects.each do |i, obj|
        objs.insert i, obj
      end

      objs
    else
      # we only have rejects, return them without calling embedly
      rejects.collect{|i, obj| obj}
    end
  end

  # Returns structured data from the services API method.
  #
  # Response is cached per API object.
  #
  # see http://api.embed.ly/docs/service for a description of the response.
  def services
    if not @services
      host, port = uri_parse(hostname)
      response = Net::HTTP.start(host, port) do |http|
        http.get('/1/services/ruby', {'User-Agent' => user_agent})
      end
      raise 'services call failed', response if response.code.to_i != 200
      @services = JSON.parse(response.body)
    end
    @services
  end

  # Returns a regex suitable for checking urls against for non-Pro usage
  def services_regex
    r = services.collect {|p| p["regex"].join("|")}.join("|")
    Regexp.new r
  end

  # Performs api call based on method name
  #
  # === Currently supported
  #
  # - +oembed+
  # - +objectify+
  # - +preview+ _pro-only_
  #
  def method_missing(name, *args, &block)
    if @endpoints.include?name
      opts = args[0]
      opts[:action] = name
      opts[:version] = @api_version[name]
      apicall opts
    else
      super
    end
  end

  private
  def uri_parse uri
    uri =~ %r{^(http(s?)://)?([^:/]+)(:([\d]+))?(/.*)?$}
    host = $3
    port = $5 ? $5 : ( $2 ? 443 : 80)
    [host, port.to_i]
  end

  def logger
    @logger ||= Embedly.logger('API')
  end

end
