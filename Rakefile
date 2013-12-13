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
  gem.name = "stacks"
  gem.homepage = "http://github.com/3dna/stacks"
  gem.license = "MIT"
  gem.summary = 'Fancy redis-backed caches'
  gem.description = 'Fancy redis-backed caches'
  gem.email = "david@nationbuilder.com"
  gem.authors = ["David Huie"]
end

Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec
