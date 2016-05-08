#####################################################################
# Example: "AVR attiny13"                                           #
# Author: Evgeny Danilov                                            #
# Created at 2016-04-26                                             #
#####################################################################

require 'rubimc'

class FirstController < AVR_attiny13
    def initialize
        boolean :@global_test
        @global_test = true

        output :@led, port: :B, pin: 3
        input :@button, port: :B, pin: 1

        ANALOG_TO_DIGITAL.init(ref: "vcc", channel: ADC0)

        ANALOG_TO_DIGITAL.interrupt(enabled: true) do |volts|
            @led.off if volts < 30
            @led.on if @button.low?
        end
    end

    def main_loop # # infinit loop, it stop only when IC is reset
        @led.toggle if (not @button.hi?) || @global_test
        @led.off if @global_test
    end
end