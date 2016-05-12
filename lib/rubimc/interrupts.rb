# List of firmware interrupts (store C-code as string)
class RubimCode::Interrupts

	@@interrupt_array = []

	def self.array
		@@interrupt_array
	end

	def self.add(val)
		if val.class.name == "String"
			@@interrupt_array << val
		else
			RubimCode.perror "wrong params in method #{__method__}"
		end
	end

	def self.print
		@@interrupt_array.each do |interrupt_code|
			RubimCode.pout interrupt_code
			end
	end
end # end RubimCode::Interrupts class