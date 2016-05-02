#####################################################################
# Example: "AVR attiny13"                                           #
# Author: Evgeny Danilov                                            #
# Created at 2016-04-26                                             #
#####################################################################

require 'rubimc'

class FirstController < AVR_attiny13
    def initialize
        @viar = integer :@viar
        @viar .c_assign=  RubimCode::UserVariable.new(12)

        ANALOG_TO_DIGITAL.init(ref: "vcc", channel: ADC0)

        ANALOG_TO_DIGITAL.interrupt(enabled: true) do |volts|
            output :led, port: :B, pin:  RubimCode::UserVariable.new(3)
            led.off if RubimCode.rubim_ifmod volts <  RubimCode::UserVariable.new(30); RubimCode.rubim_end;
            led.on if RubimCode.rubim_ifmod volts >=  RubimCode::UserVariable.new(220); RubimCode.rubim_end;
        end

        @viar .c_assign=  RubimCode::UserVariable.new(123)
    end

    def main_loop # # infinit loop, it stop only when IC is reset
        qwe = integer :qwe
        qwe .c_assign=  RubimCode::UserVariable.new(12)
    end
end