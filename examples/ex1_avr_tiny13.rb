#####################################################################
# NOTE!                                                             #
# To compile this example you must use 'rubim-compile' script       #
# Replace this examples in root directory of RubimC.                #
# Generated C-code and binary files will placed in folder "release" #
#                                                                   #
# Example: "AVR attiny13"                                           #
# Author: Evgeny Danilov                                            #
# Created at 2016-04-26                                             #
#####################################################################

require_relative '../core/core.rb'
require_relative '../lib/avr/attiny13.rb'

class FirstController < AVR_attiny13
    def initialize
        ANALOG_TO_DIGITAL.init(ref: "vcc", channel: ADC0)

        ANALOG_TO_DIGITAL.interrupt(enabled: true) do |volts|
            output :led, port: :B, pin: 3
            led.off if volts < 30
            led.on if volts >= 220
        end
    end

    def main_loop # # infinit loop, it stop only when IC is reset
    end
end