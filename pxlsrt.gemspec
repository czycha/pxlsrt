# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pxlsrt/version'

Gem::Specification.new do |spec|
  spec.name          = 'pxlsrt'
  spec.version       = Pxlsrt::VERSION
  spec.authors       = ['EVA-01']
  spec.email         = ['j.bruno.che@gmail.com']
  spec.summary       = 'Pixel sort PNG files.'
  spec.description   = 'Pixel sort PNG files with ease!'
  spec.homepage      = 'https://github.com/czycha/pxlsrt'
  spec.license       = 'MIT'

  spec.files         = ['lib/pxlsrt.rb', 'lib/pxlsrt/colors.rb', 'lib/pxlsrt/helpers.rb', 'lib/pxlsrt/brute.rb', 'lib/pxlsrt/smart.rb', 'lib/pxlsrt/version.rb', 'lib/pxlsrt/lines.rb', 'lib/pxlsrt/image.rb', 'lib/pxlsrt/kim.rb', 'lib/pxlsrt/spiral.rb', 'lib/pxlsrt/seed.rb']
  spec.executables   = ['pxlsrt']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.2'
  spec.add_dependency 'oily_png', '~> 1.2.1'
  spec.add_dependency 'thor', '~> 0.18'
end
