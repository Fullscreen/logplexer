# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logplexer/version'

Gem::Specification.new do |spec|
  spec.name          = "logplexer"
  spec.version       = Logplexer::VERSION
  spec.authors       = ["Ryan Canty"]
  spec.email         = ["jrcanty@gmail.com"]

  spec.summary       = %q{ Multiplex all the logs }
  spec.description   = %q{ Multiplexes logs to different places depending on environment }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"

  spec.add_runtime_dependency "honeybadger"
end
