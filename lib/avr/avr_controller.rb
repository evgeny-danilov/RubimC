class AVRController < Controllers
	def self.print_layout(position)
		if position == :before_main
			print_cc_layout(:before_main) do 
				micro_layout # prints includes for current microcontroller
			end 
		elsif position == :after_main
			print_cc_layout(:after_main)
		end
	end
end