def clear_str(str)
	str.gsub(/[\n\t]/, "")
end

def before_input(str)
	$before_input = PreProcessor.execute(str)
end

def input_set(str)
	str = PreProcessor.execute(str)
	$test_mcu.instance_eval ("
		def test_code
			#{$before_input}
			$outstr = ''
			#{str}
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

