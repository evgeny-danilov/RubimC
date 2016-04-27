def clear_str(str)
	str.gsub(/[\n\t]/, "")
end

def before_input(str)
	$test_mcu.instance_eval ("
		def before_test
			#{str}
		end")
	$test_mcu.before_test
	$outstr = ''
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

class RubimCode
	def self.pout(str)
		$outstr += clear_str(str)
	end

	def self.perror(error_message)
		$outstr = "Custom Error"
	end
end
