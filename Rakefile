require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

task default: :test

RSpec::Core::RakeTask.new('test:spec') do |t|
  e = ENV['E'] # match specs by name
  f = ENV['F'] # match specs by filename

  extra_opts = if e.nil? && f.nil?
                 '-f progress'
               else
                 '--fail-fast -f documentation'
               end

  extra_opts << " -e #{e}" unless e.nil?

  t.pattern = 'spec/**/*_spec.rb'
  t.pattern = "spec/**/*#{f}*_spec.rb" unless f.nil?

  t.rspec_opts = "#{extra_opts} -b -c --tag ~benchmark"
end

desc 'Run test suite'
task test: ['test:spec']
