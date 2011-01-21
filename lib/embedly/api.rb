require 'net/http'
require 'json'
require 'ostruct'

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
#   obj = api.oembed(:url => 
#
# Call parameters should be passed as the opts parameter.  If set, key will
# automatically be added to the query string of the call, so no need to set it.
#
# This API _would_ be future compatible, if not for the version.  In order to
# add support for a new method, you will need to add a version to the
# api_version hash.  Here is an example.
#
#   api = Embedly::API.new
#   api.api_version['new_method'] = 3
#   api.new_method :arg1 => '1', :arg2 => '2'
#
class Embedly::API
  attr_reader :key, :endpoint, :api_version, :user_agent

  # === Options
  #
  # [:+endpoint+] Hostname of embedly server.  Defaults to api.embed.ly if no key is provided, pro.embed.ly if key is provided.
  # [:+key+] Your pro.embed.ly api key.
  # [:+user_agent+] Your User-Agent header.  Defaults to Mozilla/5.0 (compatible; embedly-ruby/VERSION;)
  def initialize opts={}
    @key = opts[:key]
    if @key
      logger.debug('using pro')
      @endpoint = opts[:endpoint] || 'pro.embed.ly'
    else
      @endpoint = opts[:endpoint] || 'api.embed.ly'
    end
    @api_versions = Hash.new('1').merge!({'objectify' => '2'})
    @user_agent = opts[:user_agent] || "Mozilla/5.0 (compatible; embedly-ruby/#{Embedly::VERSION};)"
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

    if opts[:urls].size == 1
      params = {:url => opts[:urls].first}
    else
      params = {:urls => opts[:urls]}
    end

    params[:key] = key if key
    params.merge!Hash[
      opts.select{|k,_| not [:url, :urls, :action, :version].index k}
    ]

    path = "/#{opts[:version]}/#{opts[:action]}?#{q params}"

    ep = endpoint
    ep = "http://#{ep}" if endpoint !~ %r{^https?://.*}
    logger.debug { "calling #{ep}#{path}" }

    url = URI.parse(ep)
    response = Net::HTTP.start(url.host, url.port) do |http|
      http.get(path, {'User-Agent' => user_agent})
    end

    # passing url vs. urls causes different things to happen on errors (like a
    # 404 for the URL).  using the url parameter returns a non 200 error code
    # in the response.  Using urls causes an error json object to be returned,
    # but the main call will still be status 200.  Below, we try to canonize as
    # best we can but it should really be changed server side.
    if response.code.to_i == 200
      logger.debug { response.body }
      # [].flatten is to be sure we have an array
      objs = [JSON.parse(response.body)].flatten.collect {|o| OpenStruct.new(o)}
    else
      objs = OpenStruct.new :type => 'error', :error_code => response.code.to_i
    end

    if objs.size == 1
      objs.first
    else
      objs
    end
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
    opts = args[0]
    opts[:action] = name
    opts[:version] = @api_versions[name]
    apicall opts
  end

  private
  # Escapes url parameters
  # TODO: move to utils
  def escape s
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/u) do
      '%'+$1.unpack('H2'*$1.bytesize).join('%').upcase
    end.tr(' ', '+')
  end

  # Creates query string
  # TODO: move to utils
  def q params
    params.collect do |k,v|
      if v.is_a?Array
        "#{k.to_s}=#{v.collect{|i|escape(i)}.join(',')}"
      else
        "#{k.to_s}=#{escape(v)}"
      end
    end.join('&')
  end

  def logger
    @logger ||= Embedly.logger('API')
  end

end
