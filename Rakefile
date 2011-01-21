require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "embedly"
    gem.summary = %Q{Ruby Embedly client library}
    gem.description = %Q{Ruby Embedly client library}
    gem.email = "bob@embed.ly"
    gem.homepage = "http://github.com/embedly/embedly-ruby"
    gem.authors = ["Bob Corsaro"]
    gem.add_development_dependency "cucumber", ">= 0"
    gem.add_development_dependency "jeweler", ">= 0"
    gem.add_development_dependency "rspec", ">= 0"
    gem.add_development_dependency "grancher", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  task :features do
    abort "Cucumber is not installed"
  end
end

begin
  require 'grancher/task'
  Grancher::Task.new do |g|
    g.branch = 'gh-pages'
    g.push_to = 'origin'
    g.message = 'Updated website'

    g.directory 'website'
    g.directory 'rdoc', 'doc'
    g.file 'README.rdoc'
  end
rescue LoadError
  task :publish do
    abort "Grancher is not installed"
  end
end

task :features => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "embedly #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
