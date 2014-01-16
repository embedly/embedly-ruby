require "spec_helper"

module Embedly
  describe Configuration do

    let(:config) { Configuration.new }

    describe "debug and logging" do
      let(:logger) { Logger.new(STDERR) }

      it "has debugger disabled by default" do
        config.should_not have_debug_enabled
      end

      it "has default logger level as error" do
        config.logger.level.should == Logger::ERROR
      end

      it "can enable debugging" do
        config.debug = true
        config.should have_debug_enabled
      end

      it "can disable debugging" do
        config.debug = false
        config.should_not have_debug_enabled
      end

      it "can change the logger" do
        config.logger = logger
        config.logger.should === logger
      end

      it "sets the logger level for the new logger" do
        config.debug  = true
        config.logger = logger
        config.logger.level.should == Logger::DEBUG
      end

      it "changes the logger level when enable debugging" do
        config.debug = true
        config.logger.level.should == Logger::DEBUG
      end
    end

    describe "setting options" do
      it "sets the api key" do
        config.key = 'my_api_key'
        config.key.should == 'my_api_key'
      end

      it "requests using Net::HTTP by default" do
        config.requester.should == :net_http
      end
    end

    describe "registering a requester" do
      it "adds a new requester" do
        config.add_requester :sample do |api|
          Embedly::NetHTTP::Request.new(api)
        end
        config.request_with :sample
        config.current_requester.call({}).should be_a(Embedly::NetHTTP::Request)
      end
    end
  end
end

RSpec::Matchers.define :have_debug_enabled do
  match { |actual| actual.debug? }
end
