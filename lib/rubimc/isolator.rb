#####################################################################
# Isolator check and permit variables when need to isolate block
# For example, it`s run when execute block for fireware interrupts
# It`s done because in C interrupts executed in isolate scope
#####################################################################

class RubimCode::Isolator
	class << self
		attr_accessor :outside_binding # binding outside of block
		attr_accessor :local_variables # list of block-local variables
		attr_accessor :enabled
	end

	# return true if "var" is block-local or instance variable
	def self.permit!(var)
		return unless self.enabled
		return unless self.outside_binding
		return unless var.is_a? RubimCode::UserVariable
		return unless var.type.in? RubimCode::C_TYPES

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
end
# === END class RubimCode::Isolator === #
