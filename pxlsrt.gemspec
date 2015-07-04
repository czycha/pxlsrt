# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pxlsrt/version'
Gem::Specification.new do |spec|
  spec.name          = "pxlsrt"
  spec.authors       = ["EVA-01"]
  spec.email         = ["j.bruno.che@gmail.com"]
  spec.summary       = %q{Pixel sort PNG files.}
  spec.description   = %q{Pixel sort PNG files with ease!}
  spec.homepage      = "https://github.com/EVA-01/pxlsrt"
  spec.license       = "MIT"
  spec.version       = PxlsrtJ::VERSION
  spec.files         = ["lib/pxlsrt.rb", "lib/pxlsrt/java.rb", "lib/pxlsrt/pxlsrt.jar", "lib/pxlsrt/version.rb"]
  spec.executables   = ["pxlsrt"]
  spec.platform      = "java"
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.2"
  spec.add_dependency "thor", "~> 0.18"
end
