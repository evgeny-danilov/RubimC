#####################################################################
# It contains classes UserVariable / LoopCounter
#####################################################################

class RubimCode

	# Class of variables defined in user program
	# Variables defined with initialization helpers (integer, float, e.t.)
	class UserVariable

		attr_accessor :name, :type

		def initialize(name, type = "undefined")
			@name, @type = name.to_s, type.to_s
		end

		def to_s
			"(" + self.name + ")"
		end

		def to_i
			self.name.to_i
		end

		def to_bool
			return true   if self.name == true   || self.name =~ (/(true|t|yes|y|1)$/i)
			return false  if self.name == false  || self.name.blank? || self.name =~ (/(false|f|no|n|0)$/i)
			RubimCode.perror "Can not convert variable #{self} to boolean"
		end

		def to_rubim
			self
		end

		# Override assignment operator
		# See PreProcessor#replace_assing_operators
		def c_assign=(val)
			RubimCode::Isolator.permit!(self)
			RubimCode::Isolator.permit!(val)

			RubimCode.perror "Undefined variable or method" if val.nil?
			RubimCode.perror "Wrong match types" unless val.is_a? UserVariable

			RubimCode.pout "#{self.name} = #{val};"
		end

		# Generate "for(;;)" loop
		def times
			n = LoopCounter.new
			RubimCode.pout ("for (int #{n}=0; #{n}<#{self}; #{n}++) {")
			RubimCode.level += 1
			yield(n)
			RubimCode.pout ("}")
			RubimCode.level -= 1
		end

		# Arithmetic Operators:
		def +(val);	common_operator(val, __method__); end
		def -(val);	common_operator(val, __method__); end
		def *(val);	common_operator(val, __method__); end
		def /(val);	common_operator(val, __method__); end
		def %(val);	common_operator(val, __method__); end
		def **(val);common_operator(val, __method__); end

		# Operators +=, -=, e.t.
		# ToDo: (can not override; use preprocessor)

		# Unary Operators:
		def -@; common_operator(nil, __method__, unary: true); end
		def +@; common_operator(nil, __method__, unary: true); end
		def !@; common_operator(nil, __method__, unary: true); end
		def ~@; common_operator(nil, __method__, unary: true); end

		# Comparison Operators:
		def ==(val); common_operator(val, __method__); end
		def !=(val); common_operator(val, __method__); end
		def  <(val); common_operator(val, __method__); end
		def  >(val); common_operator(val, __method__); end
		def <=(val); common_operator(val, __method__); end
		def >=(val); common_operator(val, __method__); end

		# Binary Operators:
		def &(val); common_operator(val, __method__); end
		def |(val); common_operator(val, __method__); end
		def ^(val); common_operator(val, __method__); end
		def <<(val); common_operator(val, __method__); end
		def >>(val); common_operator(val, __method__); end

		# Logical Operators: (and, or, not, &&, ||)
		def _and(val); common_operator(val, "&&"); end
		def _or(val); common_operator(val, "||"); end
		# Note: operator 'not' replaced to "!" (sometimes bug)

		# Ternary Operators: (? :)
		# ToDo...

		# Ruby Parallel Assignment :
		# a, b, c = 10, 20, 30 
		# ToDo: use preprocessor: => [a, b, c].c_assing= 10, 20, 30

		# ToDo: операторы, которым нет аналогов в Си
		# def <=>(val);	??? end
		# def ===(val);	??? end
		# def =~(val);	??? end
		# def !~(val);	??? end

		# Range-operators ".." and "..."
		# ToDo: add mixins Enumerable and Comparable
		# ToDo: is it need? or use Enumerator?

		# All ruby operators must execute this method
		private
			def common_operator(val, operator_sym, **options)
				if not val.class.respond_to? :to_s
					RubimCode.perror "Conversion of variable #{val} is impossible. Method 'to_s' not found"
				else 
					if options[:unary]
						RubimCode::Isolator.permit!(self)
						UserVariable.new(operator_sym.to_s[0] + self.name, 'expression')
					else
						RubimCode::Isolator.permit!(self)
						RubimCode::Isolator.permit!(val)
						UserVariable.new(self.name + operator_sym.to_s + val.to_s, 'expression')
					end
				end
			end
	end # end UserVariable class


	# ToDo: в Ruby присваивание значений индексной переменной 
	# не должно влиять на выполнение цикла
	# например следующий цикл будет выполнен ровно 10 раз
	# for var in 1..10; var = var+2; end
	class LoopCounter < UserVariable
		def initialize
			name = "i" + RubimCode.level.to_s
			# ToDo - вместо "i" - __rubim__i
			super(name)
		end

		def to_s
			self.name
		end
	end # end LoopCounter class


end 
# === END class RubimCode === #

