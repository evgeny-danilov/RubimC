## TODO before push on GitHub
1. login in GitHub
2. push on GitHub

## RubimC
**RubimC** is a Ruby compiler and generator of C-code. Full name RubimCode in Russian transcription heard as "cut down the code". Current version is working but realizes far not all the features of Ruby. All realized features you can find in folder "examples"

## Description:
**RubimC** designed to simplify the process of programming microcontrollers, but can also be used as an clear С-code generator. The generator is a syntax-flavored **Ruby** combines the unique features of the **Ruby**, adding and expanding the functions required for a specific area. At the input  generator takes the program to **Ruby**, and the output provides a pure C code, based on the user program and libraries that are connected to a select model of the microcontroller. All that is required to generate is installed ruby-interpreter. If it`s nessesary, for compile C-code you need installing compiler *gcc* or *avr-gcc* (for AVR microcontrollers)

## Benefits of writing programs in RubymC 
    - increase development speed; 
    - code readability and elegance inherent in the Ruby language; 
    - an object-oriented approach; 
    - the use of an interpreted language does not reduce the performance of the final program becфuse there is no virtual mashine;
     - ability of hardware control IC and delivery of messages; 
     - ability to get a list of the hardware for a particular version of the device, as well as a list of all methods and help them directly from the generator console, on the basis of libraries.

## Why?
First of all for fan...I want to see at Ruby from other point, not only from famous framework Ruby On Rails. Of course, we have great project [mruby] (http://mruby.org/), that compile Ruby code, realized all common functions of Ruby and standart libraries, and supported by **Matz**. But...mruby generate a big-size code, and, as we know, microcontroller have very small memory. For example, for initialize only one array mruby generate binary file with size 1MB! At the other side RubimC generate code with minimal size, in most cases are not different from the similar size, written on clear C. In addition, RubimC generator is clearness. You always can to see on generated C-code and to evaluate its performance and size.

## How it`s work
Code generated in three stage:
1. Preprocessing user programm, that replaced some Ruby keywords, operators and identificators;
2. Shell Ruby-code and generate C-code (use metaprograming of Ruby);
3. Compile C-code (with gcc or avr-gcc).

## Install (Ubuntu)
All you need to use **RubimC** is Ruby interpretator and gcc/avr-gcc compiler. 

The first step is to install some dependencies for Ruby.
```sh
sudo apt-get update
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
```

Then install Ruby with *rbenv*
```sh
cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash

rbenv install 2.3.0
rbenv global 2.3.0
ruby -v
```

Compiler *gcc* provided by Ubuntu. To install *avr-gcc*:
```sh
sudo apt-get install avr-gcc avr-binutils avr-libc avrdude 
```

## ToDo list (main of them):
1. Release project as ruby-gem
2. Code generator:
    + validate ruby-program before compile
    + define user`s variables as local (now it defined in top-level instance)
    + support array, hash, string and range type
    + support user`s methods and classes
    + support threads
3. Write libraries for microcontrollers (AVR, PIC, STM, e.t.)
4. Add generators like Rails (for example: rubimc generate avr_controller Brain type:attiny13 receive_buffer:usb)
5. Fix a lot of possible bugs & features

## Example for AVR microcontroller:
Ruby programm (*"FirstController.rb"*):
```ruby
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
```

Run *rubim-compile-avr* script in console:
```sh
./rubim-compile-avr FirstController.rb
```

that generate C-code (placed in *"release/FirstController.rb.c"*)
```c
//=============================
#include <stdbool.h>

#define F_CPU 1000000UL
#include <avr/io.h>
#include <avr/iotn13.h>
#include <avr/interrupt.h>

int main() 
{
    // Init ADC
    ADMUX = (0<<REFS0) | (0<<ADLAR) | MUX0;
    ADCSRA = (1<<ADEN) | (0<<ADATE) | (1<<ADPS0) | (0<<ADIE);

    ADMUX |= 1<<ADIE;
    return 1;
}

// ADC Interrupt
ISR(ADC_vect)
{
    int __rubim__volt = ADCL + ((ADCH&0b11) << 8);
    DDRB |= 1<<(3);
    if ((__rubim__volt<=(0))) {
        PORTB &= 255 ^ (1<<(3));
    }
    if (!((__rubim__volt<(15)))) {
        PORTB |= 1<<(3);
    }
}
```
*note: this is a valid C-code, but in real AVR-controllers it may not work, because avr-libraries are still in development*

## Some interesting idea
There is interesting idea for connect few microconrollers (IC) via some firmware interfaces, for example I2C or USB **(at this moment is not realized)**. This example will generate two binary files for each microcontroller. 

```ruby
class BrainController < AVR_atmega16
    def initialize()
        input :button, port: :A, pin: 6 # its a syntax surag of "@button = input name: 'button', port: 'A', pin: 6"
    end

    def main_loop() # infinit loop, it stop only when IC is reset
        if want_to_say_hello?
            LeftHandController.move_hand = "up" # transfer data to other controller
        end
    end

    private # define user`s methods and classes
        def want_to_say_hello?
            @button.press?
        end
end

class LeftHandController < AVR_attiny13
    attr_accessor :move_hand, via: "I2C" # I2C - fireware data-transfer bus

    def move_hand=(message) # execute when command is received
        @led.toggle
        if message=="up" 
            # ...run motor...
        end
    end

    def initialize()
        output :led, port: :B, pin: 3
    end

    def main_loop() # infinit loop, it stop only when IC is reset
    end
end
```

## Help
If you interested the project and find some bugs, you may to write the tests and we try to fix it. Examples of tests is placed in folder *tests*. To run tests use command *"rspec tests/test_all.rb"*.

Thank you!