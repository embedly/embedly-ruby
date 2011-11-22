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
  end
end
