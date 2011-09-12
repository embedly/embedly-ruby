require "spec_helper"

module Embedly
  describe API do
    let(:api) { API.new :key => ENV['EMBEDLY_KEY'] }

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
        io.string.should =~ %r{DEBUG -- : calling http://api.embed.ly/1/oembed?}
      end
    end
  end
end
