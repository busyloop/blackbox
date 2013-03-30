require "bundler/gem_tasks"

require 'rspec/core/rake_task'

task :default => :test

RSpec::Core::RakeTask.new("test:spec") do |t|
  e = ENV['E'] # match specs by name
  f = ENV['F'] # match specs by filename

  if e.nil? and f.nil?
    extra_opts = '-f progress'
  else
    extra_opts = '--fail-fast -f documentation'
  end

  unless e.nil?
    extra_opts << " -e #{e}"
  end

  t.pattern = 'spec/**/*_spec.rb'
  unless f.nil?
    t.pattern = "spec/**/*#{f}*_spec.rb"
  end

  t.rspec_opts = "#{extra_opts} -b -c --tag ~benchmark"
end

desc 'Run test suite'
task :test => [ 'test:spec' ]

