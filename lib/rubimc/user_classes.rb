class RubimCode

	# ToDo
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
end # end RubimCode class