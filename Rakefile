require 'rake'
require 'bundler/gem_tasks'

require 'rubygems/package_task'
 
task :environment do
  require File.dirname(__FILE__) + '/lib/koha_client'
end
 
Dir['tasks/**/*.rake'].each { |t| load t }

task :default => ['spec:api']



task :coverage do
  # add simplecov
  ENV["COVERAGE"] = 'yes'
  # run the specs
  Rake::Task['spec:api'].execute
end
