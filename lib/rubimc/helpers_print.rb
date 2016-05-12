#####################################################################
# Helpers for print in console and in output C-files
# They сan be used directly in user program
#####################################################################

# Print comments in output C file (for clear C program)
def print_comment(comment)
	comment.lines.each do |line|
		RubimCode.pout "// #{line}"
	end
end

# Print string in console (for clear C program)
# Realize classic 'printf' function of C
def printf(str, *args)
	if args.empty?
		RubimCode.pout("printf(#{str.dump});")
	else
		args_str = args.join(', ')
		RubimCode.pout("printf(#{str.dump}, #{args_str});")
	end
end

# Paste C-code direct in generated file without any changes 
# It`s like 'asm' instruction in C code
def cc_code(str)
	RubimCode.pout "// generate with cc_code function"
	RubimCode.pout str
	RubimCode.pout "// end cc_code function"
end
