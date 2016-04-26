#####################################################################
# Initialize user`s variables										#
#####################################################################

def integer(*varies) # varies - набор инициализируемых переменных
	str = nil
	varies.each {|var|
		# ToDo - поиск уже объявленных переменных и выдача предупреждений

		if var.is_a? Hash # ToDo
			RubimCode.perror "Ошибка. В бета-версии нельзя назначать переменным значения при объявлении"
			# key = var.keys.first
			# instance_variable_set("@#{key.to_s}" , UserVariable.new("#{key.to_s}"))
			# str += "#{key.to_s}=#{var[key]}, "
		else
			# if self.ancestors.include? RubimCode or self == TestController
				str = "int " if str.nil?
				str += "#{var}, "

				eval ("
					def #{var}
						@users__var__#{var}
					end
					@users__var__#{var} = RubimCode::UserVariable.new(\"#{var}\", 'int')
					")
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
	RubimCode.pout ("#{str.chomp(', ')};") if str
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
