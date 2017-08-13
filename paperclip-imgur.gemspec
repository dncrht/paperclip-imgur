# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'paperclip-imgur'
  gem.version       = '0.1.4'
  gem.authors       = ['Daniel Cruz Horts']
  gem.description   = %q{Extends Paperclip with Imgur storage}
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/dncrht/paperclip-imgur'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'imgurapi', '>= 3.0.2'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-byebug'
end
