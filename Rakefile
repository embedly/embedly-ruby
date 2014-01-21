require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = "embedly"
  gem.summary = %Q{Ruby Embedly client library}
  gem.description = %Q{Ruby Embedly client library}
  gem.email = "bob@embed.ly"
  gem.homepage = "http://github.com/embedly/embedly-ruby"
  gem.authors = [
                 "Bob Corsaro",
                 "Felipe Elias Philipp",
                 "Russ Bradberry",
                 "Arun Thampi",
                 "Anton Dieterle",
                 "Nitesh",
                 "Roman Shterenzon",
                ]
  gem.license = "MIT"

  # in Gemfile
end
Jeweler::GemcutterTasks.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
  t.verbose = false
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
    t.files = FileList['lib/**/*.rb'].exclude('lib/jeweler/templates/**/*.rb')
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "embedly #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :all_specs => [:spec, :features]

task :default => :all_specs
