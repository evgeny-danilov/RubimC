#####################################################################
# RubimCode CORE													#
# 																	#
# Author: Evgeny Danilov											#
# Created at 2016 March-14											#
#####################################################################
class RubimCode; end

require "rubimc/ruby_classes"

require "rubimc/io_ports"
require "rubimc/controllers"
require "rubimc/mcu/avr/avr_controller"

require "rubimc/printer"
require "rubimc/init_var"
require "rubimc/control_structures"

class RubimCode
	VERSION = "0.1"

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
			@name.to_i
		end

		def to_rubim
			self
		end

		def c_assign=(val) 
			RubimCode.pout "#{@name} = #{val};"
		end

		def common_operator(val, operator_sym)
			if not val.class.respond_to? :to_s
				RubimCode.perror "Conversion of variable #{val} is impossible. Method 'to_s' not found"
			else 
				UserVariable.new(self.name + operator_sym.to_s + val.to_s)
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
		def -@; UserVariable.new("(-" + self.name + ")"); end
		def +@; UserVariable.new("(+" + self.name + ")"); end
		def !@; UserVariable.new("(+" + self.name + ")"); end
		def ~@; UserVariable.new("(+" + self.name + ")"); end

		# Comparison Operators:
		def ==(val);	common_operator(val, __method__); end
		def !=(val);	common_operator(val, __method__); end
		def  <(val);	common_operator(val, __method__); end
		def  >(val);	common_operator(val, __method__); end
		def <=(val);	common_operator(val, __method__); end
		def >=(val);	common_operator(val, __method__); end

		# Binary Operators:
		def &(val); common_operator(val, __method__); end
		def |(val); common_operator(val, __method__); end
		def ^(val); common_operator(val, __method__); end
		def <<(val); common_operator(val, __method__); end
		def >>(val); common_operator(val, __method__); end

		# Logical Operators: (and, or, not, &&, ||)
		# can not override, use preprocessor

		# Ternary Operators: (? :)
		# ToDo...

		# Ruby Parallel Assignment:
		# a, b, c = 10, 20, 30 # ToDo

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
	end

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
	end

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
	end

	# Наследник всех пользовательских классов
	class UserClass < UserVariable

		# список всех пользовательских "свойств" класса
		@@var_array = {}
		def self.add_var_array(user_class_name, value)
			@@var_array[user_class_name.to_sym] ||= []
			@@var_array[user_class_name.to_sym] << value
		end

		# получение списка всех пользовательских классов - наследников UserClass
		def self.descendants
			ObjectSpace.each_object(Class).select { |klass| klass < self }
		end # альтернативная реализация: http://apidock.com/rails/Class/descendants

		#
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
				pout_destination_is(tmp_str)
				return_var = self.new("(*params)").send(method_name).to_rubim
				pout_destination_is(:default)
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

	end

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
	end

	class CC_ARGS # class for arguments when work with clear C-code
		def count
			RubimCode::UserVariable.new("argc", "int")
		end

		def [](index)
			RubimCode::UserVariable.new("argv[#{index}]", "int")
		end
	end

end 
# === END class RubimCode === #

