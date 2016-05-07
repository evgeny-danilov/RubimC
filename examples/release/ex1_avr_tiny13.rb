#####################################################################
# Example: "AVR attiny13"                                           #
# Author: Evgeny Danilov                                            #
# Created at 2016-04-26                                             #
#####################################################################

require 'rubimc'

class FirstController < AVR_attiny13
    def initialize
        @viar, var1 = integer :@viar, :var1
        @viar .c_assign=  RubimCode::UserVariable.new(12, 'fixed')
        @viar .c_assign= ~@viar

        ANALOG_TO_DIGITAL.init(ref: "vcc", channel: ADC0)

        ANALOG_TO_DIGITAL.interrupt(enabled: true) do |volts|
            output :led, port: :B, pin:  RubimCode::UserVariable.new(3, 'fixed')
            led.off if RubimCode.rubim_ifmod volts <  RubimCode::UserVariable.new(30, 'fixed'); RubimCode.rubim_end;
            led.on if RubimCode.rubim_ifmod volts >=  RubimCode::UserVariable.new(220, 'fixed'); RubimCode.rubim_end;
            var2 = integer :var2
            var2 .c_assign=  RubimCode::UserVariable.new(3, 'fixed') + @viar
        end
    end

    def main_loop # # infinit loop, it stop only when IC is reset
        qwe = integer :qwe
        qwe .c_assign= @viar
    end
end