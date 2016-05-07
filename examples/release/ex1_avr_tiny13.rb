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

        ert = int :ert
        gerth = bool :gerth
        gerth .c_assign= RubimCode::UserVariable.new(false, 'fixed')

        name_fl = double :name_fl
        name_fl .c_assign=  RubimCode::UserVariable.new(12.4, 'fixed')
        @viar .c_assign=  RubimCode::UserVariable.new(23, 'fixed') / name_fl

        ANALOG_TO_DIGITAL.init(ref: "vcc", channel: ADC0)

        ANALOG_TO_DIGITAL.interrupt(enabled: RubimCode::UserVariable.new(true, 'fixed')) do |volts|
            output :led, port: :B, pin:  RubimCode::UserVariable.new(3, 'fixed')
            led.off if RubimCode.rubim_ifmod volts <  RubimCode::UserVariable.new(30, 'fixed'); RubimCode.rubim_end;
            led.on if RubimCode.rubim_ifmod volts >=  RubimCode::UserVariable.new(220, 'fixed'); RubimCode.rubim_end;
            RubimCode.rubim_break
        end
    end

    def main_loop # # infinit loop, it stop only when IC is reset
        qwe = integer :qwe
        qwe .c_assign= @viar
    end
end