require "spec_helper"

module Embedly
  describe API do
    let(:api) { API.new :key => ENV['EMBEDLY_KEY'], :secret => ENV['EMBEDLY_SECRET'] }

    describe "logger" do
      let(:io) { StringIO.new }

      before do
        Embedly.configure do |c|
          c.debug  = true
          c.logger = Logger.new(io)
        end
      end

      it "logs if debug is enabled" do
        api.oembed :url => 'http://blog.doki-pen.org/'
        io.string.should =~ %r{.*DEBUG -- : .*}
      end
    end

    describe "requesters" do
      describe "net/http" do
        before do
          Embedly.configure { |c| c.request_with :net_http }
        end

        it "sets the correct request adapter" do
          api.request.should be_a(Embedly::NetHTTP::Request)
        end

        it "requests succesfully" do
          request = api.oembed :url => 'http://blog.doki-pen.org/'
          request.first.provider_url.should == 'http://posterous.com'
        end
      end

      describe "typhoeus" do
        before do
          Embedly.configure { |c| c.request_with :typhoeus }
        end

        it "sets the correct request adapter" do
          api.request.should be_a(Embedly::Typhoeus::Request)
        end

        it "requests succesfully" do
          request = api.oembed :url => 'http://blog.doki-pen.org/'
          request.first.provider_url.should == 'http://posterous.com'
        end
      end
    end
  end
end
