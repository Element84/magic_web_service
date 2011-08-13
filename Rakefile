require 'rubygems'
require 'rake'
require 'rake/testtask'

lib_dir = File.expand_path('lib')
test_dir = File.expand_path('test')

Rake::TestTask.new('test') do |t|
  t.libs = [lib_dir, test_dir]
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
end
