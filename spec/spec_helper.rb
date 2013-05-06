require File.expand_path('../../lib/koha', __FILE__)
#require File.expand_path('../../lib/koha/lib', __FILE__)

require 'webmock/rspec'
if ENV["COVERAGE"] == 'yes'
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end