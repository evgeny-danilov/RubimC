/**************************************************************
 * This code was generated by RubimC micro-framework
 * RubimC version: 0.2.0
 * Author: Evgeny Danilov
 * File created at 2016-04-28 23:44:14 +0300
 **************************************************************/

#include <stdbool.h>
#include <stdio.h>

#define __AVR_ATtiny13__ 1
#define F_CPU 1000000UL
#include <avr/io.h>
#include <avr/iotn13.h>
#include <avr/interrupt.h>

int main(int argc, char *argv[]) {
    int b, c, u1;
    b = (1);
    c = (2);
    u1 = (b+(c*(b))+(b));
    int mas[3];
    int tim, mit;
    for (int i1=0; i1<(3); i1++) {
        tim = (i1+(mit)-i1);
        }
    tim = ((-15.79)+(mit)+(tim));
    
    // Init ADC
    ADMUX = (0<<REFS0) | (0<<ADLAR) | (0b10<<MUX0);
    ADCSRA = (1<<ADEN) | (0<<ADATE) | (1<<ADPS0) | (0<<ADIE);
    
    ADMUX |= 1<<ADIE;
    
    // === Main Infinite Loop === //
    while (true) {
        int __rubim__rval2 = 0;
        if ((mit)) {
            int __rubim__rval3 = 0;
            if ((tim==true)) {
                mit = (tim+(277));
                if ((mit!=(tim&false))) {
                    tim = (333);
                    }
                }
            __rubim__rval2 = __rubim__rval3;
            }
        while (true) {
            tim = (3);
            }
        __rubim__rval2 = 0;
        if (true) {
            tim = (5);
        } else if (false) {
            tim = (4);
        } else {
            tim = (0);
            __rubim__rval2 = (0);
            }
    } // end main loop
    return 1;
}

// ADC Interrupt
ISR(ADC_vect) {
    int __rubim__volt = ADCL + ((ADCH&0b11) << 8);
    DDRB |= 1<<(3);
    if ((__rubim__volt<=(0))) {
        PORTB &= ~(1<<(3));
        }
    if (!((__rubim__volt<(15)))) {
        PORTB |= 1<<(3);
        }
}
