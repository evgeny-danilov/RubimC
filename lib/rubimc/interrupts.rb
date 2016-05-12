#####################################################################
# List of firmware interrupts (store C-code as a string)
#####################################################################

class RubimCode::Interrupts

	@@interrupt_array = []

	# Add interrupt string in array
	def self.add(val)
		if val.is_a? String
			@@interrupt_array << val
		else
			RubimCode.perror "wrong params in method #{__method__}"
		end
	end

	# Shell from RubimCode::Printer.generate_cc
	def self.print
		@@interrupt_array.each do |interrupt_code|
			RubimCode.pout interrupt_code
		end
	end
end # end RubimCode::Interrupts class
