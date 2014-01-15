require "spec_helper"
require "embedly/command_line"

module Embedly
  describe CommandLine do
    after do
      ENV['EMBEDLY_KEY'] = nil
      ENV['EMBEDLY_SECRET'] = nil
    end

    describe "::run!" do
      let(:arguments) { ['-k', 'MY_KEY', '--no-secret', 'http://yfrog.com/h7qqespj', '-o', 'maxwidth=10'] }
      let(:api) { double(API) }

      it "calls api with options" do
        API.should_receive(:new).with(:key => 'MY_KEY', :headers => {}) { api }
        api.should_receive(:oembed).with(:urls => ['http://yfrog.com/h7qqespj'], :maxwidth => '10')
        CommandLine.run!(:oembed, arguments)
      end

      it "raises an error if the arguments are empty" do
        $stdout = StringIO.new
        expect {
          CommandLine.run!(:oembed, [])
        }.to raise_error(SystemExit)
      end
    end

    describe "#run" do
      before do
        API.any_instance.stub(:oembed)
      end

      describe "with option --hostname" do
        %w[-H --hostname].each do |option|
          it "sets the hostname using #{option}" do
            command([option, "sth.embed.ly"])[:hostname].should == 'sth.embed.ly'
          end
        end
      end

      describe "with --header" do
        it "sets the header" do
          command(%w[--header Header=value])[:headers].should == { 'Header' => 'value' }
        end
      end

      describe "with --key" do
        %w[-k --key].each do |option|
          it "sets the key using #{option}" do
            command([option, "SOME_KEY"])[:key].should == 'SOME_KEY'
          end
        end

        it "gets the key from environment variables if no key was set" do
          ENV['EMBEDLY_KEY'] = 'ENVIRONMENT_KEY'

          command([])[:key].should == 'ENVIRONMENT_KEY'
        end
      end

      describe "with --secret" do
        %w[-s --secret].each do |option|
          it "sets the secret using #{option}" do
            command([option, "SECRET"])[:secret].should == 'SECRET'
          end
        end

        it "gets the secret from environment variables if no secret was set" do
          ENV['EMBEDLY_SECRET'] = 'ENVIRONMENT_SECRET'

          command([])[:secret].should == 'ENVIRONMENT_SECRET'
        end
      end

      describe "with --no-key" do
        %w[-N --no-key].each do |option|
          it "unsets the key using #{option}" do
            command([option])[:key].should be_nil
          end
        end
      end

      describe "with --no-secret" do
        it "unsets the secret" do
          command(['--no-secret'])[:secret].should be_nil
        end
      end

      describe "with --no-typhoeus" do
        it "sets the request with net/http" do
          command(['--no-typhoeus'])
          Embedly.configuration.requester.should == :net_http
        end
      end

      describe "with --option" do
        %w[-o --option].each do |option|
          it "sets custom option with #{option}" do
            command([option, "maxwidth=100"])[:query][:maxwidth].should == '100'
          end
        end
      end

      describe "with --verbose" do
        it "enables logging" do
          command(["--verbose"])
          Embedly.configuration.should be_debug
        end

        it "disables logging" do
          command(["--no-verbose"])
          Embedly.configuration.should_not be_debug
        end
      end
    end

    def command(arguments)
      arguments << 'testurl.com'
      command = CommandLine.new(arguments)
      command.run
      command.options
    end
  end
end
