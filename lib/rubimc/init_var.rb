#####################################################################
# Initialize user`s variables										#
#####################################################################

class << RubimCode
	attr_accessor :binding
end

def integer(*varies) # varies - набор инициализируемых переменных
	str_cc = "int "
	ret_var = []

	varies.each {|var|
		# ToDo - поиск уже объявленных переменных и выдача предупреждений

		if var.is_a? Hash # ToDo
			RubimCode.perror "Ошибка. В бета-версии нельзя назначать переменным значения при объявлении"
			# key = var.keys.first
			# instance_variable_set("@#{key.to_s}" , UserVariable.new("#{key.to_s}"))
			# str_cc += "#{key.to_s}=#{var[key]}, "
		else
			if var.to_s[0] == '@'
				# ToDo:
				RubimCode.perror "ToDo:"
			elsif var.to_s[0] == '$'
				# ToDo or delete
				RubimCode.perror "Ошибка. В текущей версии нельзя инициализировать глобальные переменные"
			else
				str_cc += "#{var}, "
				ret_var << RubimCode::UserVariable.new("#{var}", 'int')
			end

			# if self.ancestors.include? RubimCode or self == TestController

				# str_cc = "int " if str_cc.nil?
				# str_cc += "#{var}, "

				# eval ("
				# 	def #{var}
				# 		@users__var__#{var}
				# 	end
				# 	@users__var__#{var} = RubimCode::UserVariable.new(\"#{var}\", 'int')
				# 	")

				# # Альтернативная реализация
				# var_method = Proc.new {instance_variable_get("@users__var__#{var}")}
				# self.class.send(:define_method, var.to_sym, var_method)
				# instance_variable_set("@users__var__#{var}" , UserVariable.new("#{var}", 'int'))
			# else
			# 	add_var_array(self.name, UserVariable.new("#{var}", 'int'))
			# 	eval ("
			# 			def #{var}=(value)
			# 				pout \"\#{self.name}.#{var} = \#{value};\"
			# 			end
			# 			def #{var}
			# 				UserVariable.new(\"\#{self.name}.#{var}\", 'int')
			# 			end
			# 			")
			# end
		end
	}
	if ret_var.empty?
		RubimCode.perror "no variables to init" 
	end
	RubimCode.pout ("#{str_cc.chomp(', ')};")

	if ret_var.count == 1
		return ret_var[0]
	else
		return ret_var
	end
end

def array_of_integer(var, size: nil)
	array(var, with: {type: :integer, size: size})
end

def array(var, with: {type: 'UserVariable', size: nil})
	with[:size] = with[:size].to_i
	with[:type] = with[:type].to_s
	if with[:size].nil? or with[:type].nil?
		RubimCode.perror "Необходимо указать параметры массива (напр.: with: {type: :float, size: n, ...})"
		return
	end

	user_class = with[:type]
	with[:type] = 'int' if with[:type] == 'integer'
	if (with[:type].in? ['bool','int','float','double','string']) 
		user_class = "UserVariable"
	end

	arr = with[:size].times.map do |i| 
		eval("RubimCode::#{user_class}.new('#{var}[#{i}]', '#{with[:type]}')")
	end
	instance_variable_set("@#{var}", RubimCode::UserArray.new(arr))
	eval ("@#{var}.name = '#{var}'")
	eval ("@#{var}.type = \"#{with[:type]}\"")
	RubimCode.pout "#{with[:type]} #{var}[#{with[:size]}];"
end
