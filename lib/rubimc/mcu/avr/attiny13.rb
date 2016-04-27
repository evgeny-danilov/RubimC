#####################################################################
# ATMEL AVR - attiny13												#
#####################################################################

class AVR_attiny13 < AVRController
	class << self
		def is_real_controller?
			true
		end

		def micro_layout 
			# ToDo: set F_CPU from user programm
			RubimCode.pout "#define __AVR_ATtiny13__ 1" 
			RubimCode.pout "#define F_CPU 1000000UL" # Microcontroller frequency (Hz)
			RubimCode.pout "#include <avr/io.h>"
			RubimCode.pout "#include <avr/iotn13.h>"
			RubimCode.pout "#include <avr/interrupt.h>"
		end
	end # class << self

	MICRO_NAME = "attiny13"
	PORTS = {B: (0...5)}


	RESET_PIN = {port: :B, pin: 5}

	ADC_CHANNEL = [{port: :B,pin: 5}, {port: :B, pin: 2}, {port: :B, pin: 4}, {port: :B, pin: 3}]
	AN_COMPARATOR = [{positive: {port: :B, pin: 0}, negative: {port: :B, pin: 1}}]
	ADC0="(0b00<<MUX0)"; ADC1="(0b01<<MUX0)"; ADC2="(0b10<<MUX0)"; ADC3="(0b11<<MUX0)"; 

	INTERRUPT_SOURCE = 5.times.map {|i| {port: :B, pin: i} }

	TIMER_CLOCK_SOURCE = [{port: :B, pin: 2}]
	TIMER_COMPARE_OUTPUT = [{matchA: {port: :B, pin: 0}, matchB: {port: :B, pin: 1}}]

	SPI_PIN = { master: {
					input: {port: :B, pin: 1}, 
					output: {port: :B, pin: 0} 
					}, 
				slave: {
					input: {port: :B, pin: 0}, 
					output: {port: :B, pin: 1}
					} 
				}

	class ANALOG_TO_DIGITAL
		def self.init(**options)
			options.permit_and_default!(ref: "vcc", channel: "MUX0",
							prescale: 2, auto_triggering: "disable", interrupt_enabled: false,
							digital_inputs: false)

			RubimCode.pout
			RubimCode.pout "// Init ADC"

			# === ADMUX ===
			refs0 = case options[:ref] # источник опорного напряжения
						when "vcc" then 0
						when "internal" then 1
						else perror "Undefined value for option :ref in method '#{__method__}'"
					end

			adlar = case "right" # options[:result_adjust] # выравнивание результата вычислений всегда по правому краю
						when "left" then 1
						when "right" then 0
						else perror "Undefined value for option :result_adjust in method '#{__method__}'"
					end

			channel = options[:channel]
			unless channel.in? [ADC0, ADC1, ADC2, ADC3]
				RubimCode.pout channel
				perror "Undefined value for option :channel in method '#{__method__}'"
			end

			RubimCode.pout("ADMUX = (#{refs0}<<REFS0) | (#{adlar}<<ADLAR) | #{channel};")

			# === ADCSRA ===
			adate = case options[:auto_triggering] # одиночное преобразование или множественное
						when "enable" then 1
						when "disable" then 0
						else perror "Undefined value for option :auto_triggering in method '#{__method__}'"
					end

			# adif = ? # ToDo: ADC Interrupt Flag 

			adie = 0 # interrupt enable (для установки этого значения есть отдельная функция)

			adps = case options[:prescale] # prescale
						when 2 then 1
						when 4 then 2
						when 8 then 3
						when 16 then 4
						when 32 then 5
						when 64 then 6
						when 128 then 7
						else perror "Undefined value for option :prescale in method '#{__method__}'"
					end

			RubimCode.pout ("ADCSRA = (1<<ADEN) | (#{adate}<<ADATE) | (#{adps}<<ADPS0) | (#{adie}<<ADIE);")

			# ToDo: config ports as input (is it need???)
			# ToDo: config DIDR0
			RubimCode.pout
		end # init method

		def self.convert(channel: nil)
			# ToDo: должен возвращать значение, реализовать как С-функцию
			# ToDo: можно использовать ленивую загрузку Ruby - autoload
			unless channel.in? [ADC0, ADC1, ADC2, ADC3, nil]
				perror "Undefined value for option :channel in method '#{__method__}'"
			end
			
			unless channel.nil?
				RubimCode.pout ("ADMUX = (ADMUX & 0b11111100) | channel;") # ToDo: replace 0b11111110 to ARV-const
				RubimCode.pout ("_delay_us(1);") # Для стабилизации входного напряжения # ToDo: replace to rubim's delay(1.miliseconds)
			end
			RubimCode.pout ("ADCSRA |= (1 << ADSC);") # Старт преобразования
			RubimCode.pout ("while (ADCSRA & (1 << ADSC));") # Ожидание завершения преобразования

			# ToDo - надо точно  разобраться с выравниванием
			# (и поправить аналогичный код в interrupt)
			RubimCode.pout ("ADCL + ((ADCH&0b11) << 8);") # выравнивание результата вычислений всегда по правому краю (см. adlar)
		end # convert method

		def set_freq(freq) # установка частоты АЦП (с помощью установки предделителя)
			# ToDo: реализовать метод
			# ToDo: в методе инициализации добавить опцию frequency: nil
		end

		def self.interrupt(**options, &block)
			options.permit_and_default!(enabled: false)
			# if is_enabled && block.nil? # ToDo: проверить на наличие блока если прерывание активно
			# 	perror "method #{__method__} mast have a block"
			# end

			adie = case options[:enabled] # ADC Interrupt Enable
						when true then 1
						when false then 0
						else perror "Undefined value for option :is_enabled in method '#{__method__}'"
					end
			if adie == 0 # if interrupt disabled
				RubimCode.pout "Start continuously ADC convert"
				RubimCode.pout (RubimCode.rubim_cbit("ADMUX", "ADIE"))
				# RubimCode.pout ("cli();") # automatically set (is it?) 
			else 
				RubimCode.pout (RubimCode.rubim_sbit("ADMUX", "ADIE"))
				# RubimCode.pout ("sei();") # automatically set (is it?)
			end
			
			# Genetare Interrupt code
			if block_given?
				interrupt_code = "" # Write code in variable "interrupt_code"
				RubimCode.pout_destination_is(interrupt_code)
				old_level = RubimCode.level
				RubimCode.level = 0

				RubimCode.pout
				RubimCode.pout "// ADC Interrupt"
				RubimCode.pout ("ISR(ADC_vect) {")
				RubimCode.level += 1
					# ToDo - надо точно  разобраться с выравниванием 
					# (see above in convert method)
					RubimCode.pout "int __rubim__volt = ADCL + ((ADCH&0b11) << 8);"
					yield (RubimCode::UserVariable.new("__rubim__volt", "int"))
				RubimCode.level -= 1
				RubimCode.pout ("}")

				RubimCode.level = old_level
				RubimCode.pout_destination_is(:default)
				RubimCode::Interrupts.add(interrupt_code)
			end
		end # interrupt method

	end # ANALOG_TO_DIGITAL Class 


end # RubimCode class