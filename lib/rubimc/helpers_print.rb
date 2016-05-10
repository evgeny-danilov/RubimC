# Print comments in output C file (for clear C program)
def print_comment(comment)
	comment.lines.each do |line|
		RubimCode.pout "// #{line}"
	end
end

# Print string in console (for clear C program)
# Realize classic 'printf' function in C
def printf(str, *args)
	if args.empty?
		RubimCode.pout("printf(#{str.dump});")
	else
		args_str = args.join(', ')
		RubimCode.pout("printf(#{str.dump}, #{args_str});")
	end
end

# Paste C-code direct in generated file without any changes 
def cc_code(str)
	pout "// generate with cc_code function"
	pout str
	pout "// end cc_code function"
end
