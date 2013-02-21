require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']   # optional
  t.options = ['--any', '--extra', '--opts'] # optional
end