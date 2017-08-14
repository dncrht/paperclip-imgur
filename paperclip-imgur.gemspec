$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'paperclip-imgur'
  s.version       = '0.1.5'
  s.authors       = ['Daniel Cruz Horts']
  s.description   = %q{Extends Paperclip with Imgur storage}
  s.summary       = s.description
  s.homepage      = 'https://github.com/dncrht/paperclip-imgur'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'imgurapi', '>= 3.0.2'
  s.add_development_dependency 'paperclip'
  s.add_development_dependency 'activerecord', '>= 5.1'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
end
