require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'ant'

lib_dir = File.expand_path('lib')
$LOAD_PATH << lib_dir
test_dir = File.expand_path('test')

task :default => :build_web_services

task :build_web_services do
  # Install ivy
  ant '-f install_ivy.xml'

  # Installs the spring dependencies and builds the web service jar
  ant '-f build.xml'
end

task :demo_direct_scripting do
  load 'demo_direct_scripting.rb'
end

task :demo_magic_web_service do
  load 'demo_magic_web_service.rb'
end

Rake::TestTask.new('test') do |t|
  t.libs = [lib_dir, test_dir]
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
end

