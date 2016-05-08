#####################################################################
# RubimCode CORE													#
# 																	#
# Author: Evgeny Danilov											#
# Created at 2016 March-14											#
#####################################################################
class RubimCode; end

require "version"
require "rubimc/ruby_classes"

require "rubimc/io_ports"
require "rubimc/controllers"
require "rubimc/mcu/avr/avr_controller"

require "rubimc/printer"
require "rubimc/init_var"
require "rubimc/control_structures"

class RubimCode

	class UserVariable
		attr_accessor :name, :type
		# attr_accessor :level # ToDo: для указания области видимости
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

		def c_assign=(val)
			RubimCode::Isolator.permit!(self)
			RubimCode::Isolator.permit!(val)

			RubimCode.perror "Undefined variable or method" if val.nil?
			RubimCode.perror "Wrong match types" unless val.is_a? UserVariable

			RubimCode.pout "#{self.name} = #{val};"
		end

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
		# Note: operator 'not' replaced to "!" (very bug)

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
		# ToDo: is it need? or use Enumerator?


		def times
			n = LoopCounter.new
			RubimCode.pout ("for (int #{n}=0; #{n}<#{self}; #{n}++) {")
			RubimCode.level += 1
			yield(n)
			RubimCode.pout ("}")
			RubimCode.level -= 1
		end

		# ToDo: add mixins Enumerable and Comparable

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

	class UserArray < Array
		attr_accessor :name, :type

		def []=(index, val)
			RubimCode.pout "#{@name}[#{index.to_i}] = #{val.to_s};"
		end

		def [](index)
			super index.to_i
		end

		def each
			n = LoopCounter.new
			RubimCode.pout "for (int #{n}=0; #{n}<#{self.size}; #{n}++) {"
			RubimCode.level +=1
			joy_name = self.name + "[#{n}]"
			yield(self[0].class.new("#{joy_name}"))
			RubimCode.level -=1
			RubimCode.pout "}"
		end
	end # end UserArray class

	# Наследник всех пользовательских классов
	class UserClass < UserVariable

		# список всех пользовательских "свойств" класса
		@@var_array = {}
		def self.add_var_array(user_class_name, value)
			@@var_array[user_class_name.to_sym] ||= []
			@@var_array[user_class_name.to_sym] << value
		end

		# генерация класса (typedef struct + методы)
		def self.generate_struct
			RubimCode.pout "typedef struct {"
			RubimCode.level +=1
			@@var_array[self.to_s.to_sym].each do |var| 
				RubimCode.pout "#{var.type} #{var.name};"
			end
			RubimCode.pout "} #{self.to_s};"
			RubimCode.level -=1

			public_instance_methods(false).each do |method_name| 
				tmp_str = ""
				pout_destination = tmp_str
				return_var = self.new("(*params)").send(method_name).to_rubim
				pout_destination = :default
				return_var.type = "void" if return_var.type.nil? # if type is not set

				RubimCode.pout "#{return_var.type} #{method_name.to_s} (#{self.to_s} *params) {"
				RubimCode.level += 1
					self.new("(*params)").send(method_name)
					RubimCode.pout "return #{return_var};"
					RubimCode.pout "}"
				RubimCode.level -= 1
			end
		end

		def self.redefine_users_methods
			public_instance_methods(false).each do |method_name|
				define_method(method_name) do
					"#{__method__}(&#{self.name})" 
				end
			end
		end

	end # end UserClass class

	# Список аппаратных прерываний (содержит Си-код в текстовом виде)
	class Interrupts
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
	end # end Interrupts class

	class Isolator
		class << self
			attr_accessor :outside_binding
			attr_accessor :local_variables
			attr_accessor :enabled
		end

		def self.permit!(var)
			return unless self.enabled
			return unless self.outside_binding
			return unless var.is_a? UserVariable
			return if var.type.in? ["fixed", "expression", "undefined", nil]
			return if var.type === /^tmp/

			if !local_variables.include?(var.name) and 
				outside_binding.local_variable_defined?(var.name.to_sym)
					RubimCode.perror "Undefined variable '#{var.name}'. To pass params in interruprts use instance variables: '@#{var.name}'"
			end
		end

		def self.run
	        self.local_variables = []
			self.enabled = true
		end

		def self.stop
			self.enabled = false
		end
	end # end Isolator class

	class CC_ARGS # class for arguments when work with clear C-code
		def count
			RubimCode::UserVariable.new("argc", "int")
		end

		def [](index)
			RubimCode::UserVariable.new("argv[#{index}]", "int")
		end
	end # end CC_ARGS class

end 
# === END class RubimCode === #

