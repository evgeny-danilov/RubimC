def RubimCode.init_io(mcu_class, rb_type, var, port: nil, pin: nil, type: "normal")
	if port.nil? or pin.nil?
		RubimCode.perror "Необходимо указать порт и пин для выхода #{var}"
	elsif not mcu_class::PORTS.include? port.to_sym
		RubimCode.perror "У микроконтроллера #{mcu_class::MCU_NAME} нет порта #{port}"
	elsif not mcu_class::PORTS[port.to_sym].include? pin.to_i
		RubimCode.perror "У микроконтроллера #{mcu_class::MCU_NAME} нет порта пина #{pin} для порта #{port}"
	elsif not var.is_a? Symbol
		RubimCode.perror "Unknown type of parameters for helper #{__method__}"
	end

	if type == "normal"
		var_name = var.to_s.gsub(/^[@$]/, "")
		if rb_type == 'output'
			return RubimCode::UserOutput.new(var_name, port: port, pin: pin, type: type)
		elsif rb_type == 'input'
			return RubimCode::UserInput.new(var_name, port: port, pin: pin, type: type)
		end

	elsif type == "tri-state"
		RubimCode.perror "В данный момент тип выхода 'z-state' не реализован"

	else
		RubimCode.perror "Неизвестный тип выхода '#{type}'"
	end
end

def output(var, port: nil, pin: nil)
	RubimCode.init_io(self.class, 'output', var, port: port, pin: pin)
end

def input (var, port: nil, pin: nil)
	RubimCode.init_io(self.class, 'input', var, port: port, pin: pin)
end


class RubimCode
	class << self
		def rubim_sbit(var, bit); "#{var} |= 1<<#{bit};"; end
		def rubim_cbit(var, bit); "#{var} &= ~(1<<#{bit});"; end
		def rubim_tbit(var, bit); "#{var} ^= 1<<#{bit};"; end
	end # class << self

	class UserIO
		attr_accessor :name, :port, :pin, :type

		def initialize(name, port: nil, pin: nil, type: "normal")
			# ToDo: check type of params:
			# name, port - only symbol
			# pin - only UserVariable with type 'fixed' (feature: pin can receive also instance vars: @pin_num)
			# type - only 'normal' (feature: realize 'tri-state' type)
			@name = name.to_s
			@port = port.to_s
			@pin = pin.name.to_s
			@type = type.to_s
		end
	end # end UserIO class

	class UserOutput < UserIO
		def initialize(name, port: nil, pin: nil, type: "normal")
			super
			RubimCode.pout(RubimCode.rubim_sbit("DDR#{port}", "#{pin}"))
		end


		def on
			RubimCode.pout(RubimCode.rubim_sbit("PORT#{port}", "#{pin}"))
		end

		def off
			RubimCode.pout(RubimCode.rubim_cbit("PORT#{port}", "#{pin}"))
		end

		def toggle
			RubimCode.pout(RubimCode.rubim_tbit("PORT#{port}", "#{pin}"))
		end
	end # end UserInput class

	class UserInput < UserIO
		def initialize(name, port: nil, pin: nil, type: "normal")
			super
			RubimCode.pout(RubimCode.rubim_cbit("DDR#{port}", "#{pin}"))
		end


		def hi?
			"bit_is_set(PORT#{port}, #{pin})"
		end

		def low?
			"bit_is_clear(PORT#{port}, #{pin})"
		end
	end # end UserOutput class

end # end RubimCode class