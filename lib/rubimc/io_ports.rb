def output (var, port: nil, pin: nil, type: "normal")
	if port.nil? or pin.nil?
		RubimCode.perror "Необходимо указать порт и пин для выхода #{var}"
	elsif not self.class::PORTS.include? port
		RubimCode.perror "У микроконтроллера #{self.class::MCU_NAME} нет порта #{port}"
	elsif not self.class::PORTS[port].include? pin.to_i
		RubimCode.perror "У микроконтроллера #{self.class::MCU_NAME} нет порта пина #{pin} для порта #{port}"

	elsif type == "normal"
		# define_method(var.to_sym) do
		# 	instance_variable_get("@users__var__#{var}")
		# 	end
		# instance_variable_set("@users__var__#{var}" , UserOutput.new("#{var}", port: port, pin: pin, type: type))

		eval ("
			def #{var}
				@users__var__#{var}
			end
			@users__var__#{var} = RubimCode::UserOutput.new(\"#{var}\", port: port, pin: pin, type: type)
			")

	elsif type == "tri-state"
		RubimCode.perror "В данный момент тип выхода 'z-state' не реализован"

	else
		RubimCode.perror "Неизвестный тип выхода '#{type}'"
	end
end

# ToDo: realize this method
def input (var, port: nil, pin: nil)
end


class RubimCode
	class << self
		def rubim_sbit(var, bit); "#{var} |= 1<<#{bit};"; end
		def rubim_cbit(var, bit); "#{var} &= ~(1<<#{bit});"; end
		def rubim_tbit(var, bit); "#{var} ^= 1<<#{bit};"; end
	end # class << self

	class UserOutput
		attr_accessor :name, :port, :pin, :type

		def initialize(name, port: nil, pin: nil, type: "normal")
			@name = name.to_s
			@port = port.to_s
			@pin = pin.to_s
			@type = type.to_s
			RubimCode.pout (RubimCode.rubim_sbit("DDR#{port}", "#{pin}"))
		end

		def on
			RubimCode.pout (RubimCode.rubim_sbit("PORT#{port}", "#{pin}"))
		end

		def off
			RubimCode.pout (RubimCode.rubim_cbit("PORT#{port}", "#{pin}"))
		end

		def toggle
			RubimCode.pout (RubimCode.rubim_tbit("PORT#{port}", "#{pin}"))
		end
	end

end # RubimCode class