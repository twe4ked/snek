#: coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snek/version'

Gem::Specification.new do |spec|
  spec.name = 'snek'
  spec.version = Snek::VERSION
  spec.authors = ['Odin Dutton']
  spec.email = ['odindutton@gmail.com']

  spec.summary = 'Terminal multiplayer snek game made at Railscamp 19, Adelaide'
  spec.homepage = 'https://github.com/twe4ked/snek'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'terminal_game_engine', '~> 0.1.2'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
end
