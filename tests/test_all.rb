require 'rspec'

TEST_MODE = true
require_relative '../core/core'
require_relative '../core/preprocessor'

def clear_str(str)
	str.gsub(/[\n\t]/, "")
end

def input_set(str)
	$outstr = ''
	PreProcessor.execute(str)
	$test_mcu.instance_eval ("
		def test_code
			#{PreProcessor.programm}
		end")
	$test_mcu.test_code
end

def before_input(str)
	$test_mcu.instance_eval ("
		def before_test
			#{str}
		end")
	$test_mcu.before_test
	$outstr = ''
end

class RubimCode
	def self.pout(str)
		$outstr += clear_str(str)
	end

	def self.perror(str)
		puts "\nRubimC ERROR: #{str}"
	end
end


require_relative 'test_preprocessor'
require_relative 'test_core'
require_relative 'test_avr_controllers'

