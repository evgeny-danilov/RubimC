#####################################################################
# All Ruby instruction in user code replaced with PreProcessor class
#    to RubimC temporary methods
# This file contain methods to handle this temp methods
#    and puts C-version in output file
#####################################################################

# Control structures can return values that placed in temporary variables
# For prevent name collision we used list of this variables
class << RubimCode
	attr_accessor :rubim_defined_values
end
RubimCode.rubim_defined_values = []


class << RubimCode
	# generate instructions "if" & "unless"
	def rubim_cond(cond, type="if", &block)
		# ToDo: auto-define type of ret_value
		# use::  __rubim__rval__int, __rubim__rval__float, e.t.

		if @rubim_defined_values.include? @level
			pout "__rubim__rval#{@level} = 0;"
		else
			pout "int __rubim__rval#{@level} = 0;"
		end
		@rubim_defined_values << @level

		if type=="if"
			pout "if (#{cond}) {"
		elsif type=="unless"
			pout "if (!(#{cond})) {"
		end
		@level += 1 
		ret_val = yield
		pout "__rubim__rval#{@level-1} = #{ret_val};" if ret_val!="__rubim__noreturn"
		pout "}"
		@level -= 1
		return RubimCode::UserVariable.new("__rubim__rval#{@level}", 'tmp_int')
	end
	RubimCode.private_class_method :rubim_cond

	# generate instructions "while" & "until"
	def rubim_cycle(type="while", cond="true", &block)
		pout "#{type} (#{cond}) {"
		@level+=1
			yield
			pout "}"
		@level-=1
	end
	RubimCode.private_class_method :rubim_cycle

	# realize flat instructions
	def rubim_if(cond, &block); rubim_cond(cond, "if", &block); end
	def rubim_unless(cond, &block); rubim_cond(cond, "unless", &block); end
	def rubim_while(cond, &block); rubim_cycle("while", cond, &block); end
	def rubim_until(cond); rubim_cycle("until", cond, &block); end
	def rubim_loop(&block); rubim_cycle("while", "true", &block); end

	# realize modify instructions
	def rubim_ifmod(cond); pout "if (#{cond}) {"; @level+=1; true; end
	def rubim_unlessmod(cond); pout "if (!(#{cond})) {"; @level+=1; true; end
	def rubim_whilemod(cond); pout "} while (#{cond});"; @level-=1; end
	def rubim_untilmod(cond); pout "} until (#{cond});"; @level-=1; end

	# ToDo: in 'else' and 'elsif' set return_val, like in rubim_if (need to change preprocessor)
	def rubim_else(); @level-=1; pout "} else {"; @level+=1; end
	def rubim_elsif(cond); @level-=1; pout "} else if (#{cond}) {"; @level+=1; end

	def rubim_begin(); pout "{"; @level+=1; true; end
	def rubim_end(); pout "}"; @level-=1; "__rubim__noreturn"; end
	def rubim_tmpif(tmp); end

	def rubim_next; pout "continue;" end
	def rubim_break; pout "break;" end

end # end class << RubimClass
