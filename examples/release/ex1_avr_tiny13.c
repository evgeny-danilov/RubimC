/**************************************************************
 * This code was generated by RubimC micro-framework
 * RubimC version: 0.1
 * Author: Evgeny Danilov
 * File created at 2016-04-28 23:24:43 +0300
 **************************************************************/

#include <stdbool.h>
#include <stdio.h>

#define __AVR_ATtiny13__ 1
#define F_CPU 1000000UL
#include <avr/io.h>
#include <avr/iotn13.h>
#include <avr/interrupt.h>

int main(int argc, char *argv[]) {
    
    // Init ADC
    ADMUX = (0<<REFS0) | (0<<ADLAR) | (0b00<<MUX0);
    ADCSRA = (1<<ADEN) | (0<<ADATE) | (1<<ADPS0) | (0<<ADIE);
    
    ADMUX |= 1<<ADIE;
    
    // === Main Infinite Loop === //
    while (true) {
    } // end main loop
    return 1;
}

// ADC Interrupt
ISR(ADC_vect) {
    int __rubim__volt = ADCL + ((ADCH&0b11) << 8);
    DDRB |= 1<<(3);
    if ((__rubim__volt<(30))) {
        PORTB &= ~(1<<(3));
        }
    if ((__rubim__volt>=(220))) {
        PORTB |= 1<<(3);
        }
}
