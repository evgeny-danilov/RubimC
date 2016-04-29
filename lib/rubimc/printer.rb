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
		exit 0
	end

	$pout_destination = :default
	def pout_destination_is(dest)
		if dest.nil?
			perror "Wrong parameter for method #{__method__}. Set destination string"
		end

		if dest.class.name == "String" or dest == :default # dest.is_a? not work...WTF
			$pout_destination = dest
		else
			perror "Wrong parameter for method #{__method__}. Only string variable or ':default' value is permit as a parameters"
		end
	end

	def pout(str = "")
		if str.nil? or str.to_s.nil? 
			raise ArgumentError, "str is nil" 
		else
			@level = 0 if @level.nil?
			res_str = " "*4*@level + str.to_s 
			if (($pout_destination == :default) or ($pout_destination.nil?))
				puts res_str
				unless defined? TEST_MODE
					File.open("#{ARGV[0]}.c", 'a+') {|file| file.puts(res_str) }
				end
			else
				$pout_destination.concat(res_str).concat("\n")
			end
		end
	end

	def clear_c(str)
		pout "// generate with clear_c function"
		pout str
		pout "// end clear_c function"
	end


end # class << self
end # RubimCode class

class RubimCode
	def self.print_main_loop
		pout
		pout "// === Main Infinite Loop === //"
		pout "while (true) {"
			@level += 1
			yield # print body of main loop
			@level -= 1
		pout"} // end main loop"
	end

	END { # execute when user`s program is end
		exit 0 if defined? TEST_MODE
		Controllers.all.each do |controllerClass|
			@level = 0
			controllerClass.print_layout(:before_main)
			controller = controllerClass.new # print initialize section
			print_main_loop {controller.main_loop} # print body of main loop
			controllerClass.print_layout(:after_main)
			Interrupts.print
		end # each Controllers.all

		if Controllers.all.count == 0 and eval("self.private_methods.include? :main")
			@level = 0
			Controllers.print_cc_layout(:before_main)
			eval("main(CC_ARGS.new)")
			Controllers.print_cc_layout(:after_main)
		end

		# MICRO_NAME if defined? MICRO_NAME
		exit 1
		}
end