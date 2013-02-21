require "rubygems"
require 'rspec'
require 'rspec/core/rake_task'

namespace :spec do
  
  desc 'run api specs (mock out Koha dependency)'
  RSpec::Core::RakeTask.new(:api) do |t|
    
    t.pattern = [File.join('spec', 'spec_helper.rb')]
    t.pattern += FileList[File.join('spec', 'api', '**', '*_spec.rb')]
    
    t.verbose = true
    t.rspec_opts = ['--color']
  end
=begin  
  desc 'run integration specs'
  RSpec::Core::RakeTask.new(:integration) do |t|
    
    t.pattern = [File.join('spec', 'spec_helper.rb')]
    t.pattern += FileList[File.join('spec', 'integration', '**', '*_spec.rb')]
    
    t.verbose = true
    t.rspec_opts = ['--color']
  end
=end
  
end