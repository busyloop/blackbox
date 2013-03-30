# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blackbox/version'

Gem::Specification.new do |gem|
  gem.name          = "blackbox"
  gem.version       = BB::VERSION
  gem.authors       = ["Moe"]
  gem.email         = ["moe@busyloop.net"]
  gem.description   = %q{Various little helpers}
  gem.summary       = %q{Various little helpers}
  gem.homepage      = "https://github.com/busyloop/blackbox"
  gem.license       = "MPL 2.0"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "redcarpet"
  gem.add_development_dependency "yard"
end
