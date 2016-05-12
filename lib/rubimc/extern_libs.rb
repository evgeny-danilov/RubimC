class ExternLibs
	# List of header files to include in generate C-code
	@@lib_files = []

	# Add header file to list
	# Public method
	def self.add(included_file)
		old_workdir = Dir.getwd
		Dir.chdir (File.dirname(ARGV[0]) + "/..")
		if File.exist? included_file
			@@lib_files << included_file
			RubimCode::Printer.pout_destination = :h_file
			if File.dirname(included_file) == '.'
				RubimCode.pout "#include \"../#{included_file}\""
			else
				RubimCode.pout "#include \"#{included_file}\""
			end
			RubimCode::Printer.pout_destination = :default
		else
			RubimCode.perror "Can not find file #{included_file}"
		end
		Dir.chdir(old_workdir)
	end

	# Execute C-function (return string that pasted row in output C-file)
	# Public method
	def self.eval(eval_str)
		# ToDo: check if string is a c-function
		RubimCode.pout "int __rubim__extern_func_ret = #{eval_str};"
		RubimCode::UserVariable.new("__rubim__extern_func_ret", 'extern_func')
	end

	class CFunction

		# full_name - name of function with params
		# for example: "ADC_read(channel)"
		attr_accessor :full_name

		def initialize(full_name)
			@full_name = full_name
		end
	end

	# ToDo: parse header C-file and call directly from Ruby
	# Note: Parser gem CAST is stupid. 
	# Maybe it can be possible to use RDoc::Parser::C
	# Example: 
	# 	adc_lib = ExternLibs.new("test.h")
	# 	adc_lib.init()
end