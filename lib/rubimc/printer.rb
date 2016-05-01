def print_comment(comment)
	comment.lines.each do |line|
		RubimCode.pout "// #{line}"
	end
end

def printf(str, *args)
	if args.empty?
		RubimCode.pout("printf(#{str.dump});")
	else
		args_str = args.join(', ')
		RubimCode.pout("printf(#{str.dump}, #{args_str});")
	end
end


class RubimCode
class << self

	attr_accessor :level
	def level
		@level = 0 if @level.nil?
		@level
	end

	def perror(error_message)
		if error_message.nil? or error_message.to_s.nil? 
			raise ArgumentError, "error message is not string" 
		end

		error_message += "\n"
		code_ptr = caller_locations(2)
		code_ptr.each do |place| 
			place = place.to_s
			place.gsub!(/^release\/pre_/, '')
			error_message += "\tfrom #{place}\n"
		end
		puts "#ERROR: #{error_message}"
		exit 1
	end

	def pout(str = "")
		return if RubimCode::Printer.sandbox == true # don`t print output in sandbox

		if str.nil? or str.to_s.nil?
			raise ArgumentError, "str is nil"
		else
			@level = 0 if @level.nil?
			res_str = " "*4*@level + str.to_s 
			if (($pout_destination == :default) or ($pout_destination.nil?))
				puts res_str
				unless defined? TEST_MODE
					File.open("#{ARGV[0]}", 'a+') {|file| file.puts(res_str) }
				end
			else
				$pout_destination.concat(res_str).concat("\n")
			end
		end
	end

	# ToDo: remove to RubimCode::Printer
	$pout_destination = :default
	def pout_destination=(dest)
		if dest.nil?
			perror "Wrong parameter for method #{__method__}. Set destination string"
		end

		if dest.class.name == "String" or dest == :default # dest.is_a? not work...WTF
			$pout_destination = dest
		else
			perror "Wrong parameter for method #{__method__}. Only string variable or ':default' value is permit as a parameters"
		end
	end

	def clear_c(str)
		pout "// generate with clear_c function"
		pout str
		pout "// end clear_c function"
	end


end # class << self
end # RubimCode class

class RubimCode::Printer
	class << self
		attr_accessor :sandbox
	end

	def self.code_type
		if not Controllers.all.empty?
			"avr-gcc" 
		elsif Controllers.all.empty? and eval("self.private_methods.include? :main")
			"gcc"
		else
			RubimCode.perror "Can not to define type of code"
		end
	end

	def self.mcu_type
		code_type == "avr-gcc" ? Controllers.all.first::MCU_NAME : "undefined"
	end

	def self.print_main_loop
		RubimCode.pout
		RubimCode.pout "// === Main Infinite Loop === //"
		RubimCode.pout "while (true) {"
			RubimCode.level += 1
			yield # print body of main loop
			RubimCode.level -= 1
		RubimCode.pout"} // end main loop"
	end

	def self.generate_cc
		if Controllers.all.count > 1
			RubimCode.perror "In current version in one file you can define only one Controller Class"
		end

		if self.code_type == "avr-gcc" # if compile program for MCU
			Controllers.all.each do |controllerClass|
				controllerClass.print_layout(:before_main)
				controller = controllerClass.new # print initialize section
				print_main_loop {controller.main_loop} # print body of main loop
				controllerClass.print_layout(:after_main)
				RubimCode::Interrupts.print
			end # each Controllers.all

		elsif self.code_type == "gcc" # if compile clear-C program 
			if Controllers.all.empty? and eval("self.private_methods.include? :main")
				Controllers.print_cc_layout(:before_main)
				eval("main(RubimCode::CC_ARGS.new)") # execute method :main (CC_ARGS - helper for C agruments argc/argv)
				Controllers.print_cc_layout(:after_main)
			end
		end
	end

	END { # execute when user`s program is end
		exit 0 if defined? TEST_MODE
		exit 0 if sandbox == true
		self.generate_cc
		exit 0
		}
end