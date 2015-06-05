# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'empyrean/defaults'

Gem::Specification.new do |spec|
  spec.name          = 'empyrean'
  spec.version       = Empyrean::VERSION
  spec.authors       = ['nilsding', 'pixeldesu']
  spec.email         = ['nilsding@nilsding.org', 'andy@pixelde.su']
  spec.summary       = %q{Generates stats using your Twitter archive.}
  spec.description   = %q{With Empyrean, you can generate full stats of your Twitter account using your Twitter archive.}
  spec.homepage      = 'https://github.com/Leafcat/Empyrean'
  spec.license       = 'GPLv3'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
end