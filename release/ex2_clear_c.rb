#####################################################################
# NOTE!                                                             #
# To compile this example you must use 'rubim-compile-avr' script   #
# 																	#
# Example: "Clear-C code"                                         	#
# Author: Evgeny Danilov                                        	#
# Created at 2016-04-26                                         	#
#####################################################################

require_relative '../core/core.rb'

def main(argv)
	print_comment "This is clear C code, it can be compiled with 'gcc' utility"
	printf "========Run Program========\n"
	printf "Hello! I`m code generated by RubimC and compiled by gcc\n"
	printf "I have %d arguments: ", argv.count
	printf "I have #{argv.count} arguments: \n"
	argv.count.times do |i|
		printf "%s ", argv[i]
	end
	printf "\n"

	integer :b, :c, :u1
	b .c_assign=  RubimCode::UserVariable.new(1); c .c_assign=  RubimCode::UserVariable.new(2)
	u1 .c_assign= b + c*b + ( RubimCode::UserVariable.new(2)*b)

	RubimCode.rubim_if b do
		RubimCode.rubim_if c==u1 do
			b .c_assign= c +  RubimCode::UserVariable.new(27)
			u1 .c_assign=  RubimCode::UserVariable.new(33) if RubimCode.rubim_ifmod b!= c; RubimCode.rubim_end;
		end 
	end

	u1.times do |i|
		printf("now 'i' value is %d\n", i)
	end
end