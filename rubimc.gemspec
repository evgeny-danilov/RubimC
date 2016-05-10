lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version.rb'

Gem::Specification.new do |s|
  s.name        = 'rubimc'
  s.version     = "#{RubimCode::VERSION}"
  s.date        = '2016-04-27'
  s.summary     = "RubimC: Framework for MCU - #{s.version}"
  s.description = "Ruby compiler and framework for microcontrollers like AVR, PIC & STM. It was designed to simplify the process of programming microcontrollers, but can also be used as an clear С-code generator that can be compiled with gcc"
  s.authors     = ["Evgeny Danilov"]
  s.email       = 'jmelkor@rambler.ru'
  s.homepage    = 'https://github.com/jmelkor/RubimC'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  # s.add_dependency 'superators19', '~> 0'
  # s.add_development_dependency 'rspec', '~> 0'
end