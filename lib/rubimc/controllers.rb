# ToDo: rename Controllers to MCUs
class Controllers
	def self.all # list of USER`s microcontrolles
		@@controllers_array
	end

	@@controllers_array = []
	def self.inherited(child_class) # hook when define class
		@@controllers_array << child_class if child_class.is_real_controller?
	end

	def self.is_real_controller?
		false
	end

	def self.find_mcu(name)
		series_array = Controllers.descendants
		real_mcu_array = []
		series_array.each {|series| real_mcu_array += series.descendants}
		return real_mcu_array.select {|mcu| mcu.is_real_controller? and mcu::MCU_NAME == name}
	end
end
