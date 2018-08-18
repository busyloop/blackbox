# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blackbox/version'

Gem::Specification.new do |gem|
  gem.name          = 'blackbox'
  gem.version       = BB::VERSION
  gem.authors       = ['Moe']
  gem.email         = ['moe@busyloop.net']
  gem.description   = 'Various little helpers'
  gem.summary       = 'Various little helpers'
  gem.homepage      = 'https://github.com/busyloop/blackbox'
  gem.license       = 'MPL 2.0'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.3.0'

  gem.add_development_dependency 'bump'
  gem.add_development_dependency 'fuubar'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'timecop'
  gem.add_development_dependency 'yard'

  gem.add_dependency 'chronic_duration', '~> 0.10.6'
  gem.add_dependency 'gem_update_checker', '~> 0.2.0'
  gem.add_dependency 'lolcat', '~> 90.8.8'
  gem.add_dependency 'rainbow', '~> 3.0.0'
  gem.add_dependency 'versionomy', '~> 0.5.0'
end
