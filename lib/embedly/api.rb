require 'json'
require 'ostruct'
require 'embedly/configuration'
require 'embedly/model'
require 'embedly/exceptions'
require 'embedly/request'
require 'querystring'
require 'oauth'

# Performs api calls to embedly.
#
# You won't find methods.  We are using method_missing and passing the method
# name to apicall.
#
# === Currently Supported Methods
#
# * +oembed+
# * +objectify+
# * +preview+
# * +extract+
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
  attr_reader :key, :hostname, :api_version, :headers, :secret, :proxy

  # === Options
  #
  # [:+hostname+] Hostname of embedly server.  Defaults to api.embed.ly.
  # [:+key+] Your api.embed.ly key.
  # [:+secret+] Your api.embed.ly secret if you are using oauth.
  # [:+user_agent+] Your User-Agent header.  Defaults to Mozilla/5.0 (compatible; embedly-ruby/VERSION;)
  # [:+timeout+] Request timeout (in seconds).  Defaults to 180 seconds or 3 minutes
  # [:+headers+] Additional headers to send with requests.
  # [:+proxy+] Proxy settings in format {:host => '', :port => '', :user => '', :password => ''}
  def initialize opts={}
    @endpoints = [:oembed, :objectify, :preview, :extract]
    @key = opts[:key] || configuration.key
    @secret = opts[:secret] == "" ? nil : opts[:secret]
    @api_version = Hash.new('1')
    @api_version.merge!({:objectify => '2'})
    @hostname = opts[:hostname] || 'http://api.embed.ly'
    @timeout = opts[:timeout] || 180
    @headers = {
      'User-Agent' => opts[:user_agent] || "Mozilla/5.0 (compatible; embedly-ruby/#{Embedly::VERSION};)"
    }.merge(opts[:headers]||{})
    @proxy = opts[:proxy]
  end

  def _do_oauth_call path
    consumer = OAuth::Consumer.new(key, secret,
      :site => site,
      :http_method => :get,
      :scheme => :query_string)
    # our implementation is broken for header authorization, thus the
    # query_string

    access_token = OAuth::AccessToken.new consumer
    logger.debug { "calling #{site}#{path} with headers #{headers} via OAuth" }
    access_token.get path, headers
  end

  def _do_call path
    if key and secret
      _do_oauth_call path
    else
      logger.debug { "calling #{site}#{path} with headers #{headers} using #{request}" }
      uri = URI.join(hostname, path)
      request.get(uri, :headers => headers, :timeout => @timeout, :proxy => @proxy)
    end
  end

  # <b>Use methods oembed, objectify, preview and extract in favor of
  # this method.</b>
  #
  # Normalizes url and urls parameters and calls the endpoint.  url OR urls
  # must be present
  #
  # === Options
  #
  # [:+url+] _(optional)_ A single url
  # [:+urls+] _(optional)_ An array of urls
  # [:+action+] The method that should be called. ex. oembed, objectify,
  #                   preview, extract [:+version+] The api version number.
  # [_others_] All other parameters are used as query strings.
  def apicall opts
    opts[:urls] ||= []
    opts[:urls] << opts[:url] if opts[:url]

    raise 'must pass urls' if opts[:urls].size == 0

    params = {:urls => opts[:urls]}

    # store unsupported services as errors and don't send them to embedly
    rejects = []

    params[:urls].reject!.with_index do |url, i|
      if !key && url !~ services_regex
        rejects << [i,
          Embedly::EmbedlyObject.new(
            :type => 'error',
            :error_code => 401,
            :error_message => 'Embedly api key is required.'
          )
        ]
      elsif url.length > 2048
        rejects << [i,
          Embedly::EmbedlyObject.new(
            :type => 'error',
            :error_code => 414,
            :error_message => 'URL too long.'
          )
        ]
      end
    end

    if params[:urls].size > 0
      params[:key] = key if key and not secret
      params.merge!Hash[
        opts.select{|k,_| not [:url, :urls, :action, :version].index k}
      ]

      path = "/#{opts[:version]}/#{opts[:action]}?#{QueryString.stringify(params)}"

      response = _do_call path

      if response.code.to_i == 200
        logger.debug { response.body }
        # [].flatten is to be sure we have an array
        objs = [JSON.parse(response.body)].flatten.collect do |o|
          Embedly::EmbedlyObject.new(o)
        end
      else
        logger.debug { response }
        raise Embedly::BadResponseException.new(response, path)
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
      response = _do_call '/1/services/ruby'
      raise 'services call failed', response if response.code.to_i != 200
      @services = JSON.parse(response.body)
    end
    @services
  end

  # Returns a regex suitable for checking urls against for non-key usage
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
  # - +preview+
  # - +extract+
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

  def request
    configuration.current_requester.call(self)
  end

  private

  def uri_parse uri
    uri =~ %r{^((http(s?))://)?([^:/]+)(:([\d]+))?(/.*)?$}
    scheme = $2 || 'http'
    host = $4
    port = $6 ? $6 : ( scheme == 'https' ? 443 : 80)
    [scheme, host, port.to_i]
  end

  def site
    scheme, host, port = uri_parse hostname
    if (scheme == 'http' and port == 80) or (scheme == 'https' and port == 443)
      "#{scheme}://#{host}"
    else
      "#{scheme}://#{host}:#{port}"
    end
  end

  def logger
    configuration.logger
  end

  def configuration
    Embedly.configuration
  end
end
