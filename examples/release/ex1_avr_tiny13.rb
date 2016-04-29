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

require 'rubimc'

class FirstController < AVR_attiny13
    def initialize
        ANALOG_TO_DIGITAL.init(ref: "vcc", channel: ADC0)

        ANALOG_TO_DIGITAL.interrupt(enabled: true) do |volts|
            output :led, port: :B, pin:  RubimCode::UserVariable.new(3)
            led.off if RubimCode.rubim_ifmod volts <  RubimCode::UserVariable.new(30); RubimCode.rubim_end;
            led.on if RubimCode.rubim_ifmod volts >=  RubimCode::UserVariable.new(220); RubimCode.rubim_end;
        end
    end

    def main_loop # # infinit loop, it stop only when IC is reset
    end
end