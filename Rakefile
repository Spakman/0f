require "rake/testtask"
require "rubygems/package_task"

task :default => :test

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
  t.test_files = FileList.new("test/**/*_test.rb")
  t.ruby_opts << "-Itest"
  t.ruby_opts << "-w"
end
