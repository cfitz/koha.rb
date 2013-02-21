# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "koha"

Gem::Specification.new do |s|
  s.name        = "koha"
  s.summary     = "A Ruby client for Koha ILSDI interface"
  s.description = %q{Easy interface for the Koha ILSDI API (https://github.com/Koha-Community/Koha/blob/master/C4/ILSDI/Services.pm) }
  s.version     = Koha.version
  s.authors     = ["chris fitzpatrick"]
  s.email       = ["chrisfitzpat@gmail.com"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'simplecov', '0.7.1'
  s.add_development_dependency 'yard', '~> 0.8.4.1'
  s.add_development_dependency 'webmock', '~> 1.9.3'
  s.add_development_dependency 'rake', '~> 10.0.3'
  s.add_development_dependency 'rdoc', '~> 3.9.5'
  s.add_development_dependency 'rspec', '~> 2.6.0'
end