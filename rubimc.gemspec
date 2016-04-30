require_relative 'lib/version.rb'

Gem::Specification.new do |s|
  s.name        = 'rubimc'
  s.version     = "#{RubimCode::VERSION}"
  s.date        = '2016-04-27'
  s.summary     = "RubimC: Framework for MCU - #{s.version}"
  s.description = "Ruby compiler and framework for microcontrollers like AVR, PIC & STM. It was designed to simplify the process of programming microcontrollers, but can also be used as an clear С-code generator that can be compiled with gcc"
  s.authors     = ["Evgeny Danilov"]
  s.email       = 'jmelkor@rambler.ru'
  s.files       = ["README.md", "LICENSE.md", 
                      "lib/rubimc.rb", 
                      "lib/version.rb",
                      "lib/rubimc/preprocessor.rb",
                      "lib/rubimc/printer.rb",
                      "lib/rubimc/init_var.rb",
                      "lib/rubimc/io_ports.rb",
                      "lib/rubimc/control_structures.rb",
                      "lib/rubimc/ruby_classes.rb",
                      "lib/rubimc/controllers.rb",
                      "lib/rubimc/mcu/avr/avr_controller.rb",
                      "lib/rubimc/mcu/avr/attiny13.rb",

                      "bin/rubimc"
                    ]
  s.homepage    = 'https://github.com/jmelkor/RubimC'
  s.license     = 'MIT'


  s.default_executable = %q{rubimc}
  s.executables << "rubimc"
end