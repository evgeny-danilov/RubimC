#####################################################################
# Example: "AVR attiny13"                                           #
# Author: Evgeny Danilov                                            #
# Created at 2016-04-26                                             #
#####################################################################

require 'rubimc'

class FirstController < AVR_attiny13
    def initialize
        integer :@viar, :var1
        @viar = 12
        @viar = ~@viar

        ANALOG_TO_DIGITAL.init(ref: "vcc", channel: ADC0)

        ANALOG_TO_DIGITAL.interrupt(enabled: true) do |volts|
            output :led, port: :B, pin: 3
            led.off if volts < 30
            led.on if volts >= 220
            integer :var2
            var2 = 3 + @viar
        end
    end

    def main_loop # # infinit loop, it stop only when IC is reset
        integer :qwe
        qwe = @viar
    end
end