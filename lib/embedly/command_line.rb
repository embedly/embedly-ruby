require "optparse"

module Embedly
  class CommandLine

    class Parser
      attr_accessor :options

      def initialize(args)
        @options, @args = default, args
      end

      def parse!
        parser.parse!(@args)
        set_urls!
        reject_nil!
        options
      rescue OptionParser::InvalidOption => error
        puts "ERROR: #{error.message}"
        puts parser.on_tail
        exit
      end

      def self.parse!(args)
        new(args).parse!
      end

      private

      def default
        {
          :key => ENV['EMBEDLY_KEY'],
          :secret => ENV['EMBEDLY_SECRET'],
          :timeout => nil,
          :headers => {},
          :query => {}
        }
      end

      def reject_nil!
        options.reject! { |_, opt| opt.nil? }
      end

      def set_urls!
        raise(OptionParser::InvalidOption, "url required") if @args.empty?
        options[:query][:urls] = @args
      end

      def parser
        OptionParser.new do |parser|
          parser.banner = %{
Fetch JSON from the embedly service.
Usage [OPTIONS] <url> [url] ..
}

          parser.separator ""
          parser.separator "Options:"

          parser.on('-H', '--hostname ENDPOINT', 'Embedly host. Default is api.embed.ly.') do |hostname|
            options[:hostname] = hostname
          end

          parser.on("--header NAME=VALUE", "HTTP header to send with requests.") do |hash|
            header, value = hash.split '='
            options[:headers][header] = value
          end

          parser.on("-k", "--key KEY", "Embedly key [default: EMBEDLY_KEY environmental variable]") do |key|
            options[:key] = key
          end

          parser.on("-N", "--no-key", "Ignore EMBEDLY_KEY environmental variable") do |key|
            options[:key] = nil
          end

          parser.on("-s", "--secret SECRET", "Embedly secret [default: EMBEDLY_SECRET environmental variable]") do |secret|
            options[:secret] = secret
          end

          parser.on("--no-secret", "Ignore EMBEDLY_SECRET environmental variable") do
            options[:secret] = nil
          end

          parser.on("--timeout TIMEOUT", "Request timeout") do |timeout|
            options[:timeout] = timeout.to_i
          end

          parser.on("-o", "--option NAME=VALUE", "Set option to be passed as query param.") do |option|
            key, value = option.split('=')
            options[:query][key.to_sym] = value
          end

          parser.on("--no-typhoeus", "Don't use typhoeus.") do
            Embedly.configuration.request_with :net_http
          end

          parser.separator ""
          parser.separator "Common Options:"

          parser.on("-v", "--[no-]verbose", "Run verbosely") do |verbose|
            Embedly.configuration.debug = verbose
          end

          parser.on("-h", "--help", "Display this message") do
            puts parser
            exit
          end

          parser.separator ""
          parser.separator "Bob Corsaro <bob@embed.ly>"
        end
      end
    end

    class << self
      def run!(endpoint, args = [])
        new(args).run(endpoint)
      end
    end

    def initialize(args)
      @options, @args = {}, args
    end

    def run(endpoint = :oembed)
      api_options = options.dup
      query = api_options.delete(:query)
      Embedly::API.new(api_options).send(endpoint, query)
    end

    def options
      @options = Parser.parse!(@args.dup)
      @options
    end
  end
end
